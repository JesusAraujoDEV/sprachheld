#!/usr/bin/env python3
"""Selecciona sustantivos (genero + plural) de
github.com/gambolputty/german-nouns, priorizados por frecuencia real de
github.com/mejutoco/german-grammar-statistics. Deja "es"/"level" en blanco
para completar a mano + Gemini; "ruleId" se auto-asigna cruzando contra las
reglas de terminacion ya curadas en assets/data/gender-rules.json -- ver
docs/PLAN.md Seccion 12.

La lista de frecuencia no trae header y transcribe los umlauts en ASCII
(koennen, no können) -- se normalizan ambos lados antes de cruzar. Un
sustantivo sin match de frecuencia simplemente queda al final del orden,
no se descarta.

Uso:
    python scripts/derive_nouns.py --batch-size 200 --start 0
"""
import argparse
import csv
import json
import urllib.request
from pathlib import Path

NOUNS_CSV_URL = "https://raw.githubusercontent.com/gambolputty/german-nouns/main/german_nouns/nouns.csv"
FREQ_CSV_URL = (
    "https://raw.githubusercontent.com/mejutoco/"
    "german-grammar-statistics/master/german_top_50000_gender.csv"
)
REPO_ROOT = Path(__file__).resolve().parent.parent
EXISTING_NOUNS_PATH = REPO_ROOT / "assets" / "data" / "nouns.json"
GENDER_RULES_PATH = REPO_ROOT / "assets" / "data" / "gender-rules.json"
OUTPUT_DIR = Path(__file__).resolve().parent / "output"

GENUS_MAP = {"m": "der", "f": "die", "n": "das"}


def transliterate(word: str) -> str:
    return (
        word.lower()
        .replace("ä", "ae")
        .replace("ö", "oe")
        .replace("ü", "ue")
        .replace("ß", "ss")
    )


def load_existing_words() -> set:
    data = json.loads(EXISTING_NOUNS_PATH.read_text(encoding="utf-8"))
    return {n["word"].lower() for n in data}


def load_gender_rules():
    return json.loads(GENDER_RULES_PATH.read_text(encoding="utf-8"))


def guess_rule_id(word: str, gender: str, rules):
    endings = [
        (r["pattern"].lstrip("-"), r["id"])
        for r in rules
        if r["kind"] == "ending" and r["gender"] == gender
    ]
    endings.sort(key=lambda pair: -len(pair[0]))  # -iker antes que -er
    lower = word.lower()
    for ending, rule_id in endings:
        if lower.endswith(ending):
            return rule_id
    return None


def fetch_csv(url, fieldnames=None):
    with urllib.request.urlopen(url) as response:
        text = response.read().decode("utf-8")
    return list(csv.DictReader(text.splitlines(), fieldnames=fieldnames))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--batch-size", type=int, default=200)
    parser.add_argument("--start", type=int, default=0)
    args = parser.parse_args()

    existing = load_existing_words()
    rules = load_gender_rules()

    print("Descargando lista de frecuencia...")
    freq_rows = fetch_csv(FREQ_CSV_URL, fieldnames=["word", "gender"])
    freq_rank = {}
    for i, row in enumerate(freq_rows):
        key = transliterate(row["word"] or "")
        if key and key not in freq_rank:
            freq_rank[key] = i

    print("Descargando sustantivos (~30MB, puede tardar un poco)...")
    noun_rows = fetch_csv(NOUNS_CSV_URL)

    candidates = []
    for row in noun_rows:
        lemma = row.get("lemma", "").strip()
        pos = row.get("pos", "")
        genus = row.get("genus", "").strip()
        plural = row.get("nominativ plural", "").strip()
        if not lemma or lemma.startswith("-") or "Substantiv" not in pos:
            continue
        if genus not in GENUS_MAP:
            continue  # sin genero unico y claro (compuestos ambiguos) -- se salta
        if lemma.lower() in existing:
            continue
        rank = freq_rank.get(transliterate(lemma), 999_999)
        candidates.append((rank, lemma, GENUS_MAP[genus], plural))

    candidates.sort(key=lambda c: c[0])
    batch = candidates[args.start : args.start + args.batch_size]

    derived = []
    for _rank, lemma, gender, plural in batch:
        derived.append(
            {
                "id": lemma.lower(),
                "word": lemma,
                "gender": gender,
                "plural": plural or "-",
                "es": "",  # TODO: completar con Gemini
                "level": "",  # TODO: A1 | A2 | B1
                "ruleId": guess_rule_id(lemma, gender, rules),
            }
        )

    OUTPUT_DIR.mkdir(exist_ok=True)
    end = args.start + len(batch)
    out_path = OUTPUT_DIR / f"nouns_batch_{args.start}_{end}.json"
    out_path.write_text(json.dumps(derived, ensure_ascii=False, indent=2), encoding="utf-8")

    prompt_path = OUTPUT_DIR / f"nouns_batch_{args.start}_{end}_prompt.txt"
    words = ", ".join(f"{n['gender']} {n['word']}" for n in derived)
    prompt_path.write_text(
        "Traduce estos sustantivos alemanes (con su articulo) al espanol, para "
        "una app de aprendizaje de aleman A1-B1. Da SOLO la traduccion mas comun, "
        "una por linea, mismo orden, formato 'der/die/das Wort -> traduccion':\n\n"
        + words,
        encoding="utf-8",
    )

    print(f"{len(candidates)} sustantivos nuevos disponibles en total (no estan en nouns.json).")
    print(f"Lote generado: {out_path} ({len(batch)} sustantivos)")
    print(f"Prompt para Gemini: {prompt_path}")


if __name__ == "__main__":
    main()
