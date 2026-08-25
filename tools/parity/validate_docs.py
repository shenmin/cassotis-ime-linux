#!/usr/bin/env python3
"""Validate public Markdown encoding and local link targets."""

from __future__ import annotations

import argparse
from pathlib import Path
import re
import sys
from urllib.parse import unquote


ROOT = Path(__file__).resolve().parents[2]
LINK_RE = re.compile(r"!?\[[^]]*\]\(([^)]+)\)")


def markdown_files(root: Path) -> list[Path]:
    return sorted(
        path
        for path in root.rglob("*.md")
        if ".git" not in path.parts and "build" not in path.parts
    )


def local_target(raw_target: str) -> str | None:
    target = raw_target.strip()
    if target.startswith("<") and ">" in target:
        target = target[1 : target.index(">")]
    else:
        target = target.split(maxsplit=1)[0]
    if not target or target.startswith("#") or "://" in target:
        return None
    if target.startswith(("mailto:", "data:")):
        return None
    return unquote(target.split("#", 1)[0])


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=ROOT)
    args = parser.parse_args()
    root = args.root.resolve()
    failures: list[str] = []
    link_count = 0

    for path in markdown_files(root):
        relative = path.relative_to(root)
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError as error:
            failures.append(f"{relative}: invalid UTF-8: {error}")
            continue
        if "\ufffd" in text:
            failures.append(f"{relative}: contains a Unicode replacement character")
        for match in LINK_RE.finditer(text):
            target = local_target(match.group(1))
            if target is None:
                continue
            link_count += 1
            resolved = (path.parent / target).resolve()
            try:
                resolved.relative_to(root)
            except ValueError:
                failures.append(f"{relative}: local link escapes repository: {target}")
                continue
            if not resolved.exists():
                failures.append(f"{relative}: missing local link target: {target}")

    print(f"docs.files={len(markdown_files(root))}")
    print(f"docs.local_links={link_count}")
    print(f"docs.failures={len(failures)}")
    for failure in failures:
        print(failure, file=sys.stderr)
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
