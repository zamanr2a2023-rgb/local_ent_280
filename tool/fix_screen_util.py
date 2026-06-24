#!/usr/bin/env python3
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PRESENTATION = ROOT / "lib" / "presentation"

# Restore non-layout constants
RESTORE_CONST = [
    (r"static double get _ticketPrice => 45\.0\.r;", "static const double _ticketPrice = 45.0;"),
    (r"static double get _serviceFee => 2\.5\.r;", "static const double _serviceFee = 2.5;"),
]

HEIGHT_GETTERS = [
    "_heroHeight", "_gapBalanceToActions", "_gapActionsToSheet", "_height",
]
WIDTH_GETTERS = ["_cardWidth", "_imageSize"]
RADIUS_GETTERS = [
    "_sheetTopRadius", "_cardRadius", "_buttonRadius", "_inputRadius",
    "_imageRadius", "_radius", "_heroHeight",  # hero uses h actually
]

def fix_file(path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    for pat, repl in RESTORE_CONST:
        text = text.replace(pat, repl)

    text = text.replace(
        "separatorBuilder: (context, index) => Divider(\\n                        height: 1.h,",
        "separatorBuilder: (context, index) => Divider(\n                        height: 1.h,",
    )

    # Fix wrong suffix on known getters
    text = re.sub(
        r"static double get (_gapBalanceToActions) => (\d+)\.r;",
        r"static double get \1 => \2.h;",
        text,
    )
    text = re.sub(
        r"static double get (_gapActionsToSheet) => (\d+)\.r;",
        r"static double get \1 => \2.h;",
        text,
    )
    text = re.sub(
        r"static double get (_heroHeight) => (\d+)\.r;",
        r"static double get \1 => \2.h;",
        text,
    )
    text = re.sub(
        r"static double get (_height) => (\d+)\.r;",
        r"static double get \1 => \2.h;",
        text,
    )
    text = re.sub(
        r"static double get (_cardWidth) => (\d+)\.r;",
        r"static double get \1 => \2.w;",
        text,
    )
    text = re.sub(
        r"static double get (_imageSize) => (\d+)\.r;",
        r"static double get \1 => \2.w;",
        text,
    )

    # Remove const before Icon/... with screen util extensions
    text = re.sub(
        r"const (Icon\([^)]*\.sp[^)]*\))",
        r"\1",
        text,
    )
    text = re.sub(
        r"const (Icon\([^)]*\.sp[^)]*\))",
        r"\1",
        text,
    )

    path.write_text(text, encoding="utf-8")


def main():
    for dart in PRESENTATION.rglob("*.dart"):
        fix_file(dart)
    print("Fixed presentation files")


if __name__ == "__main__":
    main()
