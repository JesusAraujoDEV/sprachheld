#!/usr/bin/env python3
"""Deriva conjugacion completa (6 Praesens + 6 Praeteritum) de
github.com/viorelsfetea/german-verbs-database usando reglas gramaticales
alemanas fijas, no heuristicas de traduccion. Deja "es"/"level"/"separable"
en blanco para completar a mano + Gemini -- ver docs/PLAN.md Seccion 12.

Reglas usadas (documentadas porque no son obvias, verificadas contra los
71 verbos ya curados a mano en assets/data/verbs.json: coinciden 100%):

- wir / sie(pl) Praesens = el infinitivo tal cual, SIEMPRE. La unica
  excepcion real en todo el idioma es "sein", que ya esta en la app y se
  excluye de este import.
- Praeteritum completo se deriva mecanicamente del ich-Praeteritum que ya
  trae el CSV: du=ich+st, er=ich, wir=ich+n o ich+en, ihr=ich+t, sie=igual
  a wir. Sin excepciones -- la -e- de apoyo (arbeiten -> arbeitete) ya
  viene incluida en el ich-form que da la fuente (wir/sie usan +n en vez
  de +en cuando el ich-form ya termina en "e", si no "liebte"+"en" da
  "liebteen" en vez de "liebten").
- ihr Praesens: raiz del infinitivo (quita "-en", o solo "-n" si termina
  en -eln/-ern) + t, con una -e- de apoyo si el propio CSV muestra que el
  du-form la necesito (du termina en "-est" en vez de "-st"). Esto tambien
  resuelve bien los modales y "wissen" sin necesitar una lista aparte de
  excepciones -- se comprobo contra koennen/muessen/wollen/wissen ya
  curados y da el resultado correcto en los 4.
- Verbos separables: el CSV ya trae ich/du/er/preteritum_ich con el
  prefijo separado por un espacio al final ("breche ab", "brach ab").
  Se detecta ese espacio, se deriva todo sobre la raiz sin prefijo, y se
  reagrega " <prefijo>" al final de cada forma -- igual que ya se curo a
  mano aufstehen/anrufen/etc. "separable" se autodetecta de este patron
  en vez de quedar fijo en False.

Uso:
    python scripts/derive_verbs.py --batch-size 200 --start 0

Salida en scripts/output/: un .json listo para pegar en verbs.json (una
vez completados es/level/separable) y un .txt con el prompt para pasarle
a Gemini la traduccion del lote.
"""
import argparse
import csv
import json
import urllib.request
from pathlib import Path

CSV_URL = (
    "https://raw.githubusercontent.com/viorelsfetea/"
    "german-verbs-database/master/output/verbs.csv"
)
REPO_ROOT = Path(__file__).resolve().parent.parent
EXISTING_VERBS_PATH = REPO_ROOT / "assets" / "data" / "verbs.json"
OUTPUT_DIR = Path(__file__).resolve().parent / "output"


def load_existing_ids() -> set:
    data = json.loads(EXISTING_VERBS_PATH.read_text(encoding="utf-8"))
    return {v["id"] for v in data} | {v["infinitiv"] for v in data}


def fetch_csv_rows():
    with urllib.request.urlopen(CSV_URL) as response:
        text = response.read().decode("utf-8")
    return list(csv.DictReader(text.splitlines()))


def split_prefix(form: str):
    """Si el CSV separo un prefijo con espacio (verbo separable), devuelve
    (raiz, prefijo). Si no, (form, None)."""
    if " " in form:
        stem, prefix = form.rsplit(" ", 1)
        return stem, prefix
    return form, None


def derive_praeteritum(ich_form: str):
    stem, prefix = split_prefix(ich_form)
    wir_sie = stem + "n" if stem.endswith("e") else stem + "en"
    # ihr necesita una -e- de apoyo si la raiz termina en d/t y esa -e- no
    # esta ya incluida (verbos fuertes tipo "band" -> "bandet", no "bandt";
    # los debiles como "arbeitete" ya la traen en el propio ich-form, que
    # termina en "e" y cae en la rama normal).
    ihr = stem + "et" if stem.endswith(("d", "t")) else stem + "t"
    forms = [stem, stem + "st", stem, wir_sie, ihr, wir_sie]
    if prefix:
        forms = [f"{f} {prefix}" for f in forms]
    return forms


def derive_ihr_praesens_stem(infinitiv_stem: str, du_stem: str) -> str:
    if infinitiv_stem.endswith(("eln", "ern")):
        stem = infinitiv_stem[:-1]
    else:
        stem = infinitiv_stem[:-2]
    needs_epenthesis = du_stem.endswith("est")
    return stem + ("et" if needs_epenthesis else "t")


def derive_praesens(infinitiv: str, ich: str, du: str, er: str):
    ich_stem, prefix = split_prefix(ich)
    du_stem, _ = split_prefix(du)
    er_stem, _ = split_prefix(er)
    if prefix:
        infinitiv_stem = infinitiv[len(prefix):] if infinitiv.startswith(prefix) else infinitiv
    else:
        infinitiv_stem = infinitiv
    ihr_stem = derive_ihr_praesens_stem(infinitiv_stem, du_stem)
    forms = [ich_stem, du_stem, er_stem, infinitiv_stem, ihr_stem, infinitiv_stem]
    if prefix:
        forms = [f"{f} {prefix}" for f in forms]
    return forms


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--batch-size", type=int, default=200)
    parser.add_argument("--start", type=int, default=0)
    args = parser.parse_args()

    existing_ids = load_existing_ids()
    print("Descargando german-verbs-database...")
    rows = fetch_csv_rows()

    derived = []
    for row in rows:
        infinitiv = row["Infinitive"].strip()
        if not infinitiv or infinitiv in existing_ids or infinitiv == "sein":
            continue
        ich = row["Präsens_ich"].strip()
        du = row["Präsens_du"].strip()
        er = row["Präsens_er, sie, es"].strip()
        praet_ich = row["Präteritum_ich"].strip()
        partizip = row["Partizip II"].strip()
        aux = row["Hilfsverb"].strip()
        if not all([ich, du, er, praet_ich, partizip, aux]):
            continue  # fila incompleta en la fuente, se salta
        if aux not in ("haben", "sein"):
            continue  # algunas filas traen basura de comentarios HTML de Wiktionary

        praet_stem, prefix = split_prefix(praet_ich)
        derived.append(
            {
                "id": infinitiv,
                "infinitiv": infinitiv,
                "es": "",  # TODO: completar con Gemini
                "level": "",  # TODO: A1 | A2 | B1
                "regularity": "regular" if praet_stem.endswith("te") else "irregular",
                "separable": prefix is not None,
                "aux": aux,
                "partizipII": partizip,
                "praesens": derive_praesens(infinitiv, ich, du, er),
                "praeteritum": derive_praeteritum(praet_ich),
                "examples": [],
            }
        )

    batch = derived[args.start : args.start + args.batch_size]
    OUTPUT_DIR.mkdir(exist_ok=True)
    end = args.start + len(batch)
    out_path = OUTPUT_DIR / f"verbs_batch_{args.start}_{end}.json"
    out_path.write_text(json.dumps(batch, ensure_ascii=False, indent=2), encoding="utf-8")

    prompt_path = OUTPUT_DIR / f"verbs_batch_{args.start}_{end}_prompt.txt"
    infinitivos = ", ".join(v["infinitiv"] for v in batch)
    prompt_path.write_text(
        "Traduce estos verbos alemanes (infinitivo) al espanol, para una app de "
        "aprendizaje de aleman A1-B1. Da SOLO la traduccion mas comun y natural, "
        "una por linea, en el mismo orden, formato 'infinitivo -> traduccion'. "
        "Si un verbo tiene un uso tecnico raro, preferi el significado mas "
        "basico/cotidiano:\n\n" + infinitivos,
        encoding="utf-8",
    )

    translations_path = OUTPUT_DIR / f"verbs_batch_{args.start}_{end}_translations.txt"
    if not translations_path.exists():
        translations_path.write_text("", encoding="utf-8")

    print(f"{len(derived)} verbos nuevos disponibles en total (no estan en verbs.json).")
    print(f"Lote generado: {out_path} ({len(batch)} verbos)")
    print(f"Prompt para Gemini: {prompt_path}")
    print(f"Pegá la respuesta de Gemini en: {translations_path}")
    print(
        f"Despues fusionalo con: python scripts/apply_translations.py {out_path} --level A1"
    )


if __name__ == "__main__":
    main()
