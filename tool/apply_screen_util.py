#!/usr/bin/env python3
"""Apply flutter_screenutil suffixes to lib/presentation Dart files."""

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PRESENTATION = ROOT / "lib" / "presentation"

IMPORTS = """import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
"""

SKIP = {"app_bottom_nav.dart"}

MARGIN_PATTERNS = [
    (r"static const double _marginMobile = 20;?\n", ""),
    (r"static const double marginMobile = 20;?\n", ""),
    (r"PremiumHomeScreen\.marginMobile", "AppLayout.marginMobile"),
    (r"DeliveryScreen\._marginMobile", "AppLayout.marginMobile"),
    (r"HomeScreen\._marginMobile", "AppLayout.marginMobile"),
    (r"EventDetailScreen\._marginMobile", "AppLayout.marginMobile"),
    (r"ReservationReviewScreen\.marginMobile", "AppLayout.marginMobile"),
    (r"_marginMobile", "AppLayout.marginMobile"),
]


def add_imports(content: str) -> str:
    if "flutter_screenutil" in content:
        return content
    idx = content.find("import ")
    if idx == -1:
        return IMPORTS + content
    end = content.find(";", idx) + 1
    return content[: end + 1] + "\n" + IMPORTS + content[end + 1 :]


def strip_const_before_screenutil(content: str) -> str:
    """Remove const when followed by EdgeInsets/SizedBox/BorderRadius using .w/.h/.r/.sp"""
    content = re.sub(
        r"\bconst (EdgeInsets|SizedBox|BorderRadius|Radius)\b",
        r"\1",
        content,
    )
    return content


def apply_suffixes(content: str) -> str:
    # fontSize: 20 -> 20.sp (not already suffixed)
    content = re.sub(
        r"fontSize:\s*(\d+(?:\.\d+)?)(?!\.sp)",
        r"fontSize: \1.sp",
        content,
    )
    # size: for Icon - 22, 24, 32 etc
    content = re.sub(
        r"(?<![\w.])(size:\s*)(\d+(?:\.\d+)?)(?!\.sp)(?=\s*[,)])",
        r"\1\2.sp",
        content,
    )
    # SizedBox height/width
    content = re.sub(
        r"SizedBox\(\s*height:\s*(\d+(?:\.\d+)?)(?!\.h)",
        r"SizedBox(height: \1.h",
        content,
    )
    content = re.sub(
        r"SizedBox\(\s*width:\s*(\d+(?:\.\d+)?)(?!\.w)",
        r"SizedBox(width: \1.w",
        content,
    )
    # width: height: in BoxConstraints, Container, etc. (careful)
    for prop, suffix in [("width", "w"), ("height", "h"), ("minWidth", "w"), ("minHeight", "h"), ("maxWidth", "w"), ("maxHeight", "h")]:
        content = re.sub(
            rf"{prop}:\s*(\d+(?:\.\d+)?)(?!\.{suffix})(?=\s*[,)])",
            rf"{prop}: \1.{suffix}",
            content,
        )
    # BorderRadius.circular
    content = re.sub(
        r"BorderRadius\.circular\((\d+(?:\.\d+)?)(?!\.r)\)",
        r"BorderRadius.circular(\1.r)",
        content,
    )
    content = re.sub(
        r"Radius\.circular\((\d+(?:\.\d+)?)(?!\.r)\)",
        r"Radius.circular(\1.r)",
        content,
    )
    # EdgeInsets symmetric/all/only - numbers
    def edge_insets(m):
        inner = m.group(1)
        inner = re.sub(r"(\d+(?:\.\d+)?)(?!\.[wh])\b", lambda n: f"{n.group(1)}.w" if "horizontal" in m.group(0) or "left" in m.group(0) or "right" in m.group(0) else f"{n.group(1)}.h" if "vertical" in m.group(0) or "top" in m.group(0) or "bottom" in m.group(0) else f"{n.group(1)}.w", inner)
        return f"EdgeInsets{m.group(0)[10:]}"  # fallback simple

    content = re.sub(
        r"EdgeInsets\.symmetric\(\s*horizontal:\s*(\d+(?:\.\d+)?)(?!\.w)",
        r"EdgeInsets.symmetric(horizontal: \1.w",
        content,
    )
    content = re.sub(
        r"EdgeInsets\.symmetric\(\s*vertical:\s*(\d+(?:\.\d+)?)(?!\.h)",
        r"EdgeInsets.symmetric(vertical: \1.h",
        content,
    )
    content = re.sub(
        r"horizontal:\s*(\d+(?:\.\d+)?)(?!\.w),\s*vertical:\s*(\d+(?:\.\d+)?)(?!\.h)",
        r"horizontal: \1.w, vertical: \2.h",
        content,
    )
    content = re.sub(
        r"EdgeInsets\.all\((\d+(?:\.\d+)?)(?!\.w)\)",
        r"EdgeInsets.all(\1.w)",
        content,
    )
    content = re.sub(
        r"EdgeInsets\.fromLTRB\(\s*(\d+(?:\.\d+)?)(?!\.w),\s*(\d+(?:\.\d+)?)(?!\.h),\s*(\d+(?:\.\d+)?)(?!\.w),\s*(\d+(?:\.\d+)?)(?!\.h)",
        r"EdgeInsets.fromLTRB(\1.w, \2.h, \3.w, \4.h",
        content,
    )
    content = re.sub(
        r"padding: EdgeInsets\.only\(\s*bottom:\s*(\d+(?:\.\d+)?)(?!\.h)",
        r"padding: EdgeInsets.only(bottom: \1.h",
        content,
    )
    content = re.sub(
        r"blurRadius:\s*(\d+(?:\.\d+)?)(?!\.r)",
        r"blurRadius: \1.r",
        content,
    )
    content = re.sub(
        r"offset: const Offset\(0,\s*(-?\d+(?:\.\d+)?)\)",
        r"offset: Offset(0, \1.h)",
        content,
    )
    content = re.sub(
        r"offset: const Offset\((-?\d+(?:\.\d+)?),\s*(-?\d+(?:\.\d+)?)\)",
        r"offset: Offset(\1.w, \2.h)",
        content,
    )
    return content


def process_file(path: Path) -> None:
    if path.name in SKIP:
        return
    text = path.read_text(encoding="utf-8")
    text = add_imports(text)
    for pat, repl in MARGIN_PATTERNS:
        text = re.sub(pat, repl, text)
    text = apply_suffixes(text)
    text = strip_const_before_screenutil(text)
    path.write_text(text, encoding="utf-8")
    print(f"Updated {path.relative_to(ROOT)}")


def main():
    for dart in sorted(PRESENTATION.rglob("*.dart")):
        process_file(dart)


if __name__ == "__main__":
    main()
