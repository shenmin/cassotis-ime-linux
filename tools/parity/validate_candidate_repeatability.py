#!/usr/bin/env python3
"""Require deterministic candidate/completion traces across process layouts."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import os
from pathlib import Path
import subprocess
import sys


TEXT_FIELDS = (
    "query", "stage", "syllables", "top1", "top1_path", "top2", "top2_path",
    "suffix", "completion", "pinyin",
)


def read_trace(path: Path, expected_cases: int) -> list[dict[str, object]]:
    rows = []
    for index, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        row = json.loads(line)
        if (not isinstance(row, dict) or type(row.get("case")) is not int
                or row["case"] != index):
            raise ValueError(f"{path}: invalid case sequence at line {index}")
        if any(not isinstance(row.get(field), str) for field in TEXT_FIELDS):
            raise ValueError(f"{path}: missing text fields at case {index}")
        if not isinstance(row.get("phonetic_only"), bool):
            raise ValueError(f"{path}: invalid phonetic_only at case {index}")
        confidence = row.get("confidence")
        if isinstance(confidence, bool) or not isinstance(confidence, (int, float)):
            raise ValueError(f"{path}: missing confidence at case {index}")
        if not math.isfinite(confidence):
            raise ValueError(f"{path}: non-finite confidence at case {index}")
        rows.append(row)
    if len(rows) != expected_cases:
        raise ValueError(f"{path}: expected {expected_cases} cases, got {len(rows)}")
    return rows


def differences(reference: list[dict[str, object]],
                actual: list[dict[str, object]]) -> list[dict[str, object]]:
    if len(reference) != len(actual):
        raise ValueError("trace lengths differ")
    result = []
    for before, after in zip(reference, actual):
        fields = sorted(key for key in before.keys() | after.keys()
                        if before.get(key) != after.get(key))
        if fields:
            result.append({"case": before["case"], "fields": fields})
    return result


def run(args: argparse.Namespace) -> dict[str, object]:
    binary = args.binary.resolve(strict=True)
    dictionary = args.dictionary.resolve(strict=True)
    cases = args.cases.resolve(strict=True)
    root = args.report_dir.resolve()
    root.mkdir(parents=True, exist_ok=False)
    reference = None
    trials = []
    failures = []
    # Distinct argv/environment sizes expose stack-state dependencies. Both
    # aliases point to the same read-only database; no data or model is changed.
    for index, padding in enumerate((0, 257, 8191), 1):
        folder = root / ("run-" + str(index) + "-" + "p" * (index * 31))
        folder.mkdir()
        alias = folder / ("dictionary-" + "d" * (index * 23) + ".db")
        alias.symlink_to(dictionary)
        trace = folder / "trace.jsonl"
        log = folder / "smoke.log"
        environment = os.environ.copy()
        environment["CASSOTIS_REPEATABILITY_PADDING"] = "x" * padding
        with log.open("w", encoding="utf-8") as output:
            subprocess.run(
                [str(binary), str(alias), str(cases), str(args.limit), "0", str(trace)],
                env=environment, stdout=output, stderr=subprocess.STDOUT,
                check=True, timeout=args.timeout,
            )
        rows = read_trace(trace, args.limit)
        if reference is None:
            reference = rows
        changed = differences(reference, rows)
        if changed:
            failures.append(f"run {index}: {len(changed)} cases changed")
        canonical = json.dumps(rows, ensure_ascii=False, sort_keys=True,
                               separators=(",", ":")).encode("utf-8")
        trials.append({"run": index, "cases": len(rows),
                       "trace": str(trace), "sha256": hashlib.sha256(canonical).hexdigest(),
                       "differences": changed})
    return {"format": "cassotis-candidate-repeatability-v1", "trials": trials,
            "failures": failures, "ok": not failures}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--binary", required=True, type=Path)
    parser.add_argument("--dictionary", required=True, type=Path)
    parser.add_argument("--cases", required=True, type=Path)
    parser.add_argument("--report-dir", required=True, type=Path)
    parser.add_argument("--limit", type=int, default=500)
    parser.add_argument("--timeout", type=int, default=1800)
    args = parser.parse_args()
    if args.limit <= 0 or args.timeout <= 0:
        parser.error("limit and timeout must be positive")
    try:
        result = run(args)
    except (OSError, ValueError, subprocess.SubprocessError) as error:
        # Preserve any partial traces for diagnosis. A missing/failed run is
        # never allowed to pass by comparing two empty result sets.
        result = {"format": "cassotis-candidate-repeatability-v1",
                  "failures": [str(error)], "ok": False}
    rendered = json.dumps(result, ensure_ascii=False, indent=2) + "\n"
    sys.stdout.write(rendered)
    return 0 if result["ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
