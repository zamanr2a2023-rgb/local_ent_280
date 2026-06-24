#!/usr/bin/env python3
"""Translate app_en.arb entries that still match Portuguese (app_pt_PT.arb)."""

from __future__ import annotations

import json
import re
import sys
import time
from pathlib import Path

from deep_translator import GoogleTranslator

ROOT = Path(__file__).resolve().parents[1]
PT_PATH = ROOT / "lib" / "l10n" / "app_pt_PT.arb"
EN_PATH = ROOT / "lib" / "l10n" / "app_en.arb"
CACHE_PATH = ROOT / "scripts" / ".en_arb_translation_cache.json"

PLACEHOLDER_RE = re.compile(r"\{[a-zA-Z0-9_]+\}")

# Preserve product terms and codes inside translations.
DO_NOT_TRANSLATE = {
    "CVE",
    "EUR",
    "USD",
    "App Check",
    "Firebase",
    "Firestore",
    "FCM",
    "PDF",
    "CSV",
    "RTDB",
}


def protect_placeholders(text: str) -> tuple[str, list[str]]:
    tokens: list[str] = []

    def repl(match: re.Match[str]) -> str:
        tokens.append(match.group(0))
        return f"__PH_{len(tokens) - 1}__"

    protected = PLACEHOLDER_RE.sub(repl, text)
    return protected, tokens


def restore_placeholders(text: str, tokens: list[str]) -> str:
    restored = text
    for index, token in enumerate(tokens):
        restored = restored.replace(f"__PH_{index}__", token)
        restored = restored.replace(f"__ ph _ {index} __", token)
        restored = restored.replace(f"__PH_{index}__".lower(), token)
    return restored


def translate_text(translator: GoogleTranslator, text: str, cache: dict[str, str]) -> str:
    if text in cache:
        return cache[text]
    protected, tokens = protect_placeholders(text)
    try:
        translated = translator.translate(protected)
    except Exception as error:  # noqa: BLE001
        print(f"WARN: failed to translate: {text[:80]!r} ({error})", file=sys.stderr)
        translated = text
    translated = restore_placeholders(translated, tokens)
    cache[text] = translated
    return translated


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def main() -> int:
    pt = load_json(PT_PATH)
    en = load_json(EN_PATH)
    cache: dict[str, str] = {}
    if CACHE_PATH.exists():
        cache = json.loads(CACHE_PATH.read_text(encoding="utf-8"))

    translator = GoogleTranslator(source="pt", target="en")
    pending = [
        key
        for key, value in pt.items()
        if not key.startswith("@")
        and isinstance(value, str)
        and key in en
        and en[key] == value
    ]

    print(f"Translating {len(pending)} keys...")
    for index, key in enumerate(pending, start=1):
        source = pt[key]
        en[key] = translate_text(translator, source, cache)
        if index % 25 == 0:
            CACHE_PATH.write_text(
                json.dumps(cache, ensure_ascii=False, indent=2),
                encoding="utf-8",
            )
            print(f"  {index}/{len(pending)}")
            time.sleep(0.5)

    CACHE_PATH.write_text(
        json.dumps(cache, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )

    EN_PATH.write_text(
        json.dumps(en, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"Wrote {EN_PATH}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
