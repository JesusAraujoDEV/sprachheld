#!/usr/bin/env python3
"""Fusiona la traduccion que devolvio Gemini (una linea por palabra,
formato 'clave -> traduccion') con el lote JSON que ya genero
derive_verbs.py / derive_nouns.py. Asi Gemini nunca ve el JSON pesado
(praesens/praeteritum/etc.) -- solo traduce una lista de palabras, y la
fusion con los datos ya derivados pasa aca, localmente.

Sirve tanto para verbos (clave = infinitivo, ej. "lieben -> amar") como
para sustantivos (clave = "der/die/das Wort -> traduccion" -- el articulo
se descarta al matchear, es solo la palabra la que identifica la fila).

Uso (el archivo de traducciones se infiere del batch_json si no se pasa
-- ya lo crea vacio derive_verbs.py/derive_nouns.py, solo hay que pegarle
la respuesta de Gemini adentro):
    python scripts/apply_translations.py scripts/output/verbs_batch_0_200.json --level A1

O explicito, si el archivo de traducciones tiene otro nombre:
    python scripts/apply_translations.py \
        scripts/output/verbs_batch_0_200.json \
        scripts/output/verbs_batch_0_200_translations.txt \
        --level A1

Genera scripts/output/verbs_batch_0_200_merged.json con "es" (y "level"
si se paso --level) ya completados, listo para pegar al final de
assets/data/verbs.json o nouns.json.
"""
import argparse
import json
import re
from pathlib import Path


def parse_translations(text: str) -> dict:
    pairs = {}
    for line in text.splitlines():
        line = line.strip()
        if not line or "->" not in line:
            continue
        key, _, value = line.partition("->")
        key = key.strip()
        # Sustantivos vienen como "der/die/das Wort" -- nos quedamos solo
        # con la palabra para matchear contra "word"/"infinitiv".
        key = re.sub(r"^(der|die|das)\s+", "", key, flags=re.IGNORECASE)
        pairs[key.strip().lower()] = value.strip().rstrip(".")
    return pairs


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("batch_json", type=Path)
    parser.add_argument(
        "translations_txt",
        type=Path,
        nargs="?",
        default=None,
        help="Si se omite, se infiere reemplazando '.json' por '_translations.txt'",
    )
    parser.add_argument("--level", default=None, help='Asigna este nivel a todo el lote, ej. A1')
    args = parser.parse_args()

    translations_path = args.translations_txt or args.batch_json.with_name(
        args.batch_json.stem + "_translations.txt"
    )
    if not translations_path.exists() or not translations_path.read_text(encoding="utf-8").strip():
        print(f"ERROR: {translations_path} no existe o esta vacio.")
        print("Pega ahi la respuesta de Gemini (formato 'clave -> traduccion') y volve a correr.")
        return

    batch = json.loads(args.batch_json.read_text(encoding="utf-8"))
    translations = parse_translations(translations_path.read_text(encoding="utf-8"))

    missing = []
    for item in batch:
        key = (item.get("infinitiv") or item.get("word") or "").lower()
        if key in translations:
            item["es"] = translations[key]
        else:
            missing.append(key)
        if args.level:
            item["level"] = args.level

    out_path = args.batch_json.with_name(args.batch_json.stem + "_merged.json")
    out_path.write_text(json.dumps(batch, ensure_ascii=False, indent=2), encoding="utf-8")

    print(f"Fusionado: {out_path}")
    if missing:
        print(
            f"AVISO: {len(missing)} sin traduccion encontrada (revisa el formato "
            f"de esas lineas, tienen que decir 'clave -> traduccion'): {missing}"
        )
    if not args.level:
        print('Falta completar "level" a mano en cada objeto (o corre de nuevo con --level A1/A2/B1).')


if __name__ == "__main__":
    main()
