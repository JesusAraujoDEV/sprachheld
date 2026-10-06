#!/usr/bin/env python3
"""Deriva assets/data/word-glosses.json: un mapa plano
{ "palabra_en_minuscula": "significado en espanol" } para el feature de
traduccion palabra-por-palabra al tocar (estilo Duolingo).

A diferencia de derive_nouns.py / derive_verbs.py, este script NO baja datos
de internet ni pide traducciones a Gemini: fusiona assets que YA estan en el
repo (nouns/adjectives/verbs) con una lista cerrada de palabras funcion
escritas a mano. La salida SI es un asset de la app (se commitea), no un
output descartable de scripts/output/.

Reglas de fusion (ver .orca-brief.md Parte 1):
- Todas las keys en minuscula (incluidos sustantivos). El lookup en la app
  tambien minuscula antes de buscar.
- Primera ocurrencia gana: una fuente posterior nunca pisa una key existente.
- Fuentes en orden: nouns -> adjectives -> verbs (frequencyRank <= 1000) ->
  lista cerrada de palabras funcion.
- Garantia dura: CADA palabra de CADA frase en los *-phrases.json debe tener
  entrada. El script falla si queda alguna sin cubrir, listandolas.

Uso:
    python scripts/derive_word_glosses.py
"""
import json
import re
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
DATA_DIR = REPO_ROOT / "assets" / "data"
OUTPUT_PATH = DATA_DIR / "word-glosses.json"

VERB_FREQUENCY_CUTOFF = 1000

PHRASE_FILES = [
    "phrases.json",
    "possessive-phrases.json",
    "akkusativ-pronomen-phrases.json",
    "demonstrativ-phrases.json",
    "konjunktiv2-hoeflichkeit-phrases.json",
    "preposition-phrases.json",
]

# Palabras funcion de alta frecuencia que no viven en nouns/adjectives/verbs.
# Escritas a mano porque son gramaticales, no lexicas. Minuscula sin excepcion.
FUNCTION_WORDS = {
    # Articulos definidos (todas las formas de caso/genero)
    "der": "el / la / los (artículo)",
    "die": "la / las (artículo)",
    "das": "el / lo (artículo neutro)",
    "den": "el / a los (artículo, acusativo/dativo pl.)",
    "dem": "al / a la (artículo, dativo)",
    "des": "del (artículo, genitivo)",
    # Articulos indefinidos
    "ein": "un / uno (artículo)",
    "eine": "una (artículo)",
    "einen": "un / a un (artículo, acusativo)",
    "einem": "a un / a una (artículo, dativo)",
    "einer": "a una / de una (artículo, dativo/genitivo fem.)",
    "eines": "de un (artículo, genitivo)",
    "kein": "ningún / ninguno",
    "keine": "ninguna / ningunos",
    "keinen": "ningún (acusativo)",
    # Pronombres personales (Nominativ)
    "ich": "yo",
    "du": "tú",
    "er": "él",
    "sie": "ella / ellos / usted",
    "es": "ello / lo (neutro)",
    "wir": "nosotros",
    "ihr": "vosotros / su (de ella)",
    # Pronombres personales (Akkusativ)
    "mich": "me / a mí",
    "dich": "te / a ti",
    "ihn": "lo / a él",
    "uns": "nos / a nosotros",
    "euch": "os / a vosotros",
    # Pronombres personales (Dativ)
    "mir": "me / a mí",
    "dir": "te / a ti",
    "ihm": "le / a él",
    "ihnen": "les / a ellos / a usted",
    # Posesivos (formas basicas y declinadas comunes)
    "mein": "mi",
    "meine": "mi / mis",
    "meinen": "mi (acusativo)",
    "meinem": "a mi (dativo)",
    "meiner": "de mi / a mi (dativo fem.)",
    "dein": "tu",
    "deine": "tu / tus",
    "deinen": "tu (acusativo)",
    "sein": "su (de él)",
    "seine": "su / sus (de él)",
    "seinen": "su (de él, acusativo)",
    "seinem": "a su (de él, dativo)",
    "seiner": "de su (de él)",
    "unser": "nuestro",
    "unsere": "nuestra / nuestros",
    "euer": "vuestro",
    "eure": "vuestra / vuestros",
    # 'ihr'/'Ihr' posesivo ya cubierto por 'ihr' arriba (su de ella/ellos)
    "ihre": "su / sus (de ella / de ellos)",
    "ihren": "su (de ella/ellos, acusativo)",
    "ihrem": "a su (de ella/ellos, dativo)",
    "ihrer": "de su (de ella/ellos)",
    # Demostrativos
    "dieser": "este / esta",
    "diese": "esta / estas",
    "dieses": "este (neutro) / de este",
    "diesen": "este (acusativo) / a estos",
    "diesem": "a este (dativo)",
    "jener": "aquel",
    "jene": "aquella",
    # Preposiciones
    "in": "en / dentro de",
    "an": "en / junto a",
    "auf": "sobre / en",
    "mit": "con",
    "bei": "en casa de / cerca de",
    "nach": "hacia / después de",
    "aus": "de / desde (origen)",
    "von": "de / desde",
    "zu": "a / hacia",
    "zur": "a la (zu + der)",
    "zum": "al (zu + dem)",
    "am": "en el / al (an + dem)",
    "ins": "en el / al (in + das)",
    "im": "en el (in + dem)",
    "beim": "en el / junto al (bei + dem)",
    "vom": "del (von + dem)",
    "für": "para / por",
    "durch": "por / a través de",
    "gegen": "contra",
    "ohne": "sin",
    "um": "alrededor de / a (hora)",
    "über": "sobre / encima de",
    "unter": "debajo de / entre",
    "vor": "delante de / antes de",
    "zwischen": "entre",
    "hinter": "detrás de",
    "neben": "al lado de",
    "seit": "desde (tiempo)",
    "während": "durante",
    "wegen": "a causa de",
    "trotz": "a pesar de",
    "gegenüber": "frente a",
    "ab": "a partir de",
    "bis": "hasta",
    # Conjunciones
    "und": "y",
    "oder": "o",
    "aber": "pero",
    "weil": "porque",
    "dass": "que",
    "wenn": "si / cuando",
    "denn": "pues / porque",
    "sondern": "sino",
    "als": "cuando / que (comparación)",
    "ob": "si (interrogativa indirecta)",
    "damit": "para que",
    # Adverbios y particulas comunes
    "nicht": "no",
    "sehr": "muy",
    "auch": "también",
    "schon": "ya",
    "noch": "todavía / aún",
    "bitte": "por favor",
    "gern": "con gusto / de buena gana",
    "gerne": "con gusto / de buena gana",
    "heute": "hoy",
    "morgen": "mañana",
    "gestern": "ayer",
    "jetzt": "ahora",
    "hier": "aquí",
    "da": "ahí / allí",
    "dort": "allí",
    "immer": "siempre",
    "nie": "nunca",
    "oft": "a menudo",
    "manchmal": "a veces",
    "wieder": "otra vez / de nuevo",
    "nur": "solo / solamente",
    "mehr": "más",
    "viel": "mucho",
    "viele": "muchos",
    "wenig": "poco",
    "etwas": "algo",
    "nichts": "nada",
    "alles": "todo",
    "alle": "todos",
    "man": "uno / se (impersonal)",
    "so": "así / tan",
    "ganz": "completamente / muy",
    "ja": "sí",
    "nein": "no",
    "doch": "sí (claro que sí) / sin embargo",
    "mal": "una vez / a ver",
    "einmal": "una vez",
    "zusammen": "juntos",
    "zuhause": "en casa",
    "hause": "casa (zu Hause)",
    "links": "a la izquierda",
    "rechts": "a la derecha",
    "oben": "arriba",
    "unten": "abajo",
    "weg": "fuera / lejos",
    "bald": "pronto",
    "deutsch": "alemán",
    "jeden": "cada / todos los (acusativo)",
    "jede": "cada / toda",
    "jedes": "cada / todo (neutro)",
    "unserer": "de nuestra / a nuestra (dativo/genitivo)",
    "unseren": "nuestro (acusativo)",
    "unserem": "a nuestro (dativo)",
    # Interrogativos
    "was": "qué",
    "wer": "quién",
    "wie": "cómo",
    "wo": "dónde",
    "wann": "cuándo",
    "warum": "por qué",
    "welche": "cuál / cuáles",
    "welcher": "cuál",
    "welches": "cuál (neutro)",
    "wohin": "a dónde",
    "woher": "de dónde",
    # Modales / Konjunktiv II de cortesia (si no quedaron por los verbos)
    "hätte": "tendría / quisiera (cortesía)",
    "hätten": "tendrían / tendríamos",
    "hättest": "tendrías",
    "könnte": "podría",
    "könnten": "podrían / podríamos",
    "könntest": "podrías",
    "möchte": "quisiera / me gustaría",
    "möchten": "quisieran / quisiéramos",
    "möchtest": "quisieras",
    "würde": "haría (condicional)",
    "würden": "harían / haríamos",
    "wäre": "sería / estaría",
    "wären": "serían / estarían",
    "muss": "debe / tiene que",
    "müssen": "deber / tener que",
    "kann": "puede",
    "können": "poder",
    "will": "quiere",
    "wollen": "querer",
    "soll": "debe / debería",
    "sollen": "deber",
    "darf": "puede (permiso)",
    "dürfen": "poder (permiso)",
    "mag": "le gusta",
    "mögen": "gustar",
    # Numeros basicos
    "null": "cero",
    "eins": "uno",
    "zwei": "dos",
    "drei": "tres",
    "vier": "cuatro",
    "fünf": "cinco",
    "sechs": "seis",
    "sieben": "siete",
    "acht": "ocho",
    "neun": "nueve",
    "zehn": "diez",
}

# Palabras lexicas (adjetivos, verbos conjugados/imperativos, sustantivos) y
# nombres propios que aparecen en las frases pero no estan en los assets
# fuente (adjectives/verbs/nouns). Escritas a mano para garantizar que toda
# palabra de toda frase tenga glosa. Minuscula sin excepcion.
PHRASE_EXTRAS = {
    # Adjetivos que no estan en adjectives.json
    # Correcciones de glosas donde el sustantivo fuente trae un sentido
    # secundario/raro que confunde en el contexto de las frases (no se toca
    # nouns.json, que es contenido de dominio; ver work-log follow-up).
    "reif": "maduro",
    "alt": "viejo",
    "klein": "pequeño",
    "kaffee": "el café (bebida)",
    "tee": "el té",
    "wagen": "el coche / el carro",
    "lecker": "delicioso / rico",
    "hochzeit": "la boda",
    "rock": "la falda",
    "post": "el correo",
    "stift": "el bolígrafo / lápiz",
    "glas": "el vaso",
    "zeigen": "mostrar",
    "schule": "la escuela",
    "stelle": "pongo / coloco (de stellen)",
    "putzen": "limpiar",
    "lege": "pongo / coloco (de legen)",
    # Nombres propios adicionales (apellido y nombre que aparecen en frases)
    "müller": "Müller (apellido)",
    "tom": "Tom (nombre)",
    # Adjetivos
    "frisch": "fresco",
    "heiß": "caliente",
    "kalt": "frío",
    "warm": "cálido / caliente",
    "offen": "abierto",
    "praktisch": "práctico",
    "schlecht": "malo",
    "schmutzig": "sucio",
    "spannend": "emocionante",
    "teuer": "caro",
    "wichtig": "importante",
    "langsam": "lento / despacio",
    "langsamer": "más lento / más despacio",
    # Verbos / imperativos que no entraron por el corte de frecuencia
    "anprobieren": "probarse (ropa)",
    "reservieren": "reservar",
    "umtauschen": "cambiar / canjear",
    "trink": "¡bebe! (imperativo de trinken)",
    # Sustantivo plural sin lema en nouns.json
    "eltern": "los padres",
    # Nombres propios que aparecen en las frases
    "berlin": "Berlín (ciudad)",
    "brigitte": "Brigitte (nombre)",
    "david": "David (nombre)",
    "jesús": "Jesús (nombre)",
    "marisa": "Marisa (nombre)",
    "peter": "Peter (nombre)",
}

# Puntuacion a limpiar de los bordes al extraer palabras de las frases.
_EDGE_PUNCT = re.compile(r"^[^\wäöüßÄÖÜ]+|[^\wäöüßÄÖÜ]+$", re.UNICODE)


def strip_edges(token: str) -> str:
    return _EDGE_PUNCT.sub("", token)


def load_json(name: str):
    return json.loads((DATA_DIR / name).read_text(encoding="utf-8"))


def add(glosses: dict, key: str, meaning: str, force: bool = False) -> None:
    """Primera ocurrencia gana, salvo [force]=True (lista funcion curada,
    que debe ganarle a un sustantivo nominalizado raro: 'das Ich' no debe
    pisar el pronombre 'ich', ni 'das Schreiben' al verbo 'schreiben')."""
    key = key.strip().lower()
    if not key:
        return
    if key in glosses and not force:
        return
    if not meaning or not meaning.strip():
        return
    glosses[key] = meaning.strip()


def add_from_nouns(glosses: dict) -> None:
    for noun in load_json("nouns.json"):
        meaning = noun.get("es", "")
        word = noun.get("word", "")
        plural = noun.get("plural", "")
        add(glosses, word, meaning)
        if plural and plural != "-" and plural.lower() != word.lower():
            add(glosses, plural, meaning)


def add_from_adjectives(glosses: dict) -> None:
    # Un adjetivo comun le gana a un sustantivo nominalizado homografo
    # ('gut' adjetivo "bueno", no el sustantivo "das Gut"; 'alt' -> "viejo",
    # no "la contralto'). force=True porque los sustantivos corren antes.
    for adj in load_json("adjectives.json"):
        add(glosses, adj.get("de", ""), adj.get("es", ""), force=True)


def add_from_verbs(glosses: dict) -> None:
    """Verbos con freq <= 1000. Un mismo form conjugado puede pertenecer a
    varios verbos ('geht' = gehen y tambien formas de otros); gana el verbo
    mas frecuente (menor frequencyRank). Los verbos le ganan a un sustantivo
    nominalizado con la misma grafia, pero entre si respetan la frecuencia."""
    verbs = [
        v for v in load_json("verbs.json")
        if v.get("frequencyRank") is not None
        and v["frequencyRank"] <= VERB_FREQUENCY_CUTOFF
    ]
    verbs.sort(key=lambda v: v["frequencyRank"])
    verb_forms: dict = {}
    for verb in verbs:
        meaning = verb.get("es", "")
        forms = [verb.get("infinitiv", ""), verb.get("partizipII", "")]
        forms += verb.get("praesens", []) or []
        forms += verb.get("praeteritum", []) or []
        for form in forms:
            # Formas separables vienen como "stehe auf": cada token cuenta.
            for part in str(form).split():
                add(verb_forms, part, meaning)  # first-wins = mas frecuente
    for key, meaning in verb_forms.items():
        add(glosses, key, meaning, force=True)  # gana al sustantivo homografo


def phrase_words() -> set:
    words = set()
    for name in PHRASE_FILES:
        for entry in load_json(name):
            sentence = entry.get("sentence", "")
            answer = entry.get("answer", "")
            # La frase mostrada reemplaza ___ por la respuesta: incluir ambos.
            filled = sentence.replace("___", f" {answer} ")
            for token in filled.split():
                word = strip_edges(token).lower()
                # Los numeros (ej. numeros de telefono "862098") no son
                # palabras que valga la pena glosar.
                if word and word != "___" and not word.isdigit():
                    words.add(word)
    return words


def verify_phrase_coverage(glosses: dict) -> None:
    missing = sorted(w for w in phrase_words() if w not in glosses)
    if missing:
        raise SystemExit(
            "FALTAN glosas para palabras que aparecen en frases "
            f"({len(missing)}):\n  " + "\n  ".join(missing)
        )


def main() -> None:
    glosses: dict = {}
    add_from_nouns(glosses)
    add_from_adjectives(glosses)
    add_from_verbs(glosses)
    for key, meaning in FUNCTION_WORDS.items():
        add(glosses, key, meaning, force=True)
    for key, meaning in PHRASE_EXTRAS.items():
        add(glosses, key, meaning, force=True)

    verify_phrase_coverage(glosses)

    ordered = {k: glosses[k] for k in sorted(glosses)}
    payload = json.dumps(ordered, ensure_ascii=False, indent=2)
    OUTPUT_PATH.write_text(payload, encoding="utf-8")

    size = OUTPUT_PATH.stat().st_size
    print(f"Escrito {OUTPUT_PATH}")
    print(f"  {len(ordered)} entradas, {size} bytes ({size / 1_048_576:.2f} MB)")


if __name__ == "__main__":
    main()
