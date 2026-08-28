#!/usr/bin/env python3
"""Ensure Linux programs install the FPC thread driver before threaded units."""

from __future__ import annotations

from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
THREADED_UNITS = (
    "nc_engine_service",
    "nc_local_completion_host",
    "nc_pinyin_transformer_host",
)


def main() -> int:
    failures: list[str] = []
    checked = 0
    for program in sorted(ROOT.rglob("*.lpr")):
        text = program.read_text(encoding="utf-8-sig").lower()
        target_offsets = [
            text.find(unit_name)
            for unit_name in THREADED_UNITS
            if unit_name in text
        ]
        if not target_offsets:
            continue
        checked += 1
        cthreads_offset = text.find("cthreads")
        if cthreads_offset < 0 or cthreads_offset > min(target_offsets):
            failures.append(str(program.relative_to(ROOT)))

    if failures:
        raise AssertionError(
            "threaded entry points must load cthreads first: "
            + ", ".join(failures)
        )
    if checked == 0:
        raise AssertionError("no threaded Pascal entry points were discovered")

    print(f"threaded_entrypoints={checked}:passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
