#!/usr/bin/env python3
"""Validate the frozen Windows/lexicon baseline used by the Linux port."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
import sqlite3
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[2]
BASELINE_PATH = ROOT / "porting" / "windows-baseline.txt"
DIRECTIVE_RE = re.compile(r"^\{\$(?:codepage|mode|H\+).*$", re.IGNORECASE)


def read_baseline() -> dict[str, str]:
    values: dict[str, str] = {}
    for raw_line in BASELINE_PATH.read_text(encoding="utf-8-sig").splitlines():
        if not raw_line.strip() or raw_line.lstrip().startswith("#"):
            continue
        key, separator, value = raw_line.partition("=")
        if not separator:
            raise ValueError(f"invalid baseline line: {raw_line!r}")
        values[key.strip()] = value.strip()
    return values


def git_head(repository: Path) -> str:
    return subprocess.check_output(
        ["git", "-C", str(repository), "rev-parse", "HEAD"],
        text=True,
        encoding="utf-8",
    ).strip()


def git_worktree_clean(repository: Path) -> bool:
    status = subprocess.check_output(
        ["git", "-C", str(repository), "status", "--porcelain"],
        text=True,
        encoding="utf-8",
    )
    return not status.strip()


def normalize_generated_pascal(path: Path) -> str:
    lines: list[str] = []
    for raw_line in path.read_text(encoding="utf-8-sig").splitlines():
        stripped = raw_line.strip()
        if DIRECTIVE_RE.match(stripped):
            continue
        line = raw_line.rstrip().replace("System.", "")
        if line.strip():
            lines.append(line)
    return "\n".join(lines) + "\n"


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def validate_models(windows_root: Path) -> tuple[int, list[str]]:
    windows_engine = windows_root / "src" / "engine"
    linux_engine = ROOT / "src" / "engine"
    names = sorted(path.name for path in windows_engine.glob("nc_*_model.pas"))
    failures: list[str] = []
    if len(names) != 40:
        failures.append(f"expected 40 Windows generated models, found {len(names)}")
    for name in names:
        windows_path = windows_engine / name
        linux_path = linux_engine / name
        if not linux_path.is_file():
            failures.append(f"missing Linux model: {name}")
            continue
        if normalize_generated_pascal(windows_path) != normalize_generated_pascal(
            linux_path
        ):
            failures.append(f"generated model differs: {name}")

    evidence_name = "nc_short_context_expanded_evidence.pas"
    windows_evidence = windows_engine / evidence_name
    linux_evidence = linux_engine / evidence_name
    if not windows_evidence.is_file() or not linux_evidence.is_file():
        failures.append(f"missing expanded evidence unit: {evidence_name}")
    elif normalize_generated_pascal(windows_evidence) != normalize_generated_pascal(
        linux_evidence
    ):
        failures.append(f"expanded evidence differs: {evidence_name}")
    return len(names), failures


def validate_dictionary(
    path: Path, expected_hash: str, expected_schema: int
) -> dict[str, object]:
    expected_hash = expected_hash.lower()
    actual_hash = sha256_file(path)
    with sqlite3.connect(f"file:{path.as_posix()}?mode=ro", uri=True) as connection:
        row = connection.execute(
            "SELECT value FROM meta WHERE key = 'schema_version'"
        ).fetchone()
    schema = int(row[0]) if row else -1
    return {
        "file": path.name,
        "sha256": actual_hash,
        "expected_sha256": expected_hash,
        "schema": schema,
        "expected_schema": expected_schema,
        "ok": actual_hash == expected_hash
        and schema == expected_schema,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--windows-root", required=True, type=Path)
    parser.add_argument("--lexicon-root", required=True, type=Path)
    parser.add_argument("--dictionary", required=True, type=Path)
    parser.add_argument("--dictionary-traditional", required=True, type=Path)
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()

    baseline = read_baseline()
    failures: list[str] = []
    windows_head = git_head(args.windows_root)
    lexicon_head = git_head(args.lexicon_root)
    windows_clean = git_worktree_clean(args.windows_root)
    lexicon_clean = git_worktree_clean(args.lexicon_root)
    if windows_head != baseline["reviewed_through"]:
        failures.append(
            "Windows HEAD differs from baseline: "
            f"{windows_head} != {baseline['reviewed_through']}"
        )
    if lexicon_head != baseline["lexicon_reviewed_through"]:
        failures.append(
            "lexicon HEAD differs from baseline: "
            f"{lexicon_head} != {baseline['lexicon_reviewed_through']}"
        )
    if not windows_clean:
        failures.append("Windows baseline worktree is not clean")
    if not lexicon_clean:
        failures.append("lexicon baseline worktree is not clean")

    model_count, model_failures = validate_models(args.windows_root)
    failures.extend(model_failures)
    expected_schema = int(baseline["dictionary_schema"])
    dictionary = validate_dictionary(
        args.dictionary, baseline["dictionary_sha256"], expected_schema
    )
    if not dictionary["ok"]:
        failures.append("simplified dictionary differs from frozen baseline")
    traditional_dictionary = validate_dictionary(
        args.dictionary_traditional,
        baseline["dictionary_tc_sha256"],
        expected_schema,
    )
    if not traditional_dictionary["ok"]:
        failures.append("traditional dictionary differs from frozen baseline")

    report = {
        "format": "cassotis-source-parity-v1",
        "windows_head": windows_head,
        "windows_expected": baseline["reviewed_through"],
        "windows_worktree_clean": windows_clean,
        "lexicon_head": lexicon_head,
        "lexicon_expected": baseline["lexicon_reviewed_through"],
        "lexicon_worktree_clean": lexicon_clean,
        "generated_models": model_count,
        "expanded_evidence": True,
        "dictionary": dictionary,
        "dictionary_traditional": traditional_dictionary,
        "failures": failures,
        "ok": not failures,
    }
    rendered = json.dumps(report, ensure_ascii=False, indent=2) + "\n"
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(rendered, encoding="utf-8")
    sys.stdout.write(rendered)
    return 0 if report["ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
