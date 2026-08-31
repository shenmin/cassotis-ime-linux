#!/usr/bin/env python3
"""Validate the frozen Windows/lexicon baseline used by the Linux port."""

from __future__ import annotations

import argparse
from contextlib import closing
import hashlib
import json
from pathlib import Path
import re
import sqlite3
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[2]
BASELINE_PATH = ROOT / "porting" / "windows-baseline.txt"
SOURCE_MANIFEST_PATH = ROOT / "porting" / "source-parity-manifest.json"
DIRECTIVE_RE = re.compile(r"^\{\$(?:codepage|mode|H\+).*$", re.IGNORECASE)
DEPLOYED_MODEL_ASSETS = (
    (
        "data/models/pinyin_transformer/pinyin_conditional_scorer_int8.onnx",
        "pinyin_transformer_model_sha256",
    ),
    (
        "data/models/pinyin_transformer/vocab.json",
        "pinyin_transformer_vocab_sha256",
    ),
    (
        "data/models/pinyin_transformer/pinyin_parallel_generator_int8.onnx",
        "pinyin_parallel_generator_sha256",
    ),
    (
        "data/models/pinyin_transformer/pinyin_parallel_allowed.bin",
        "pinyin_parallel_allowed_sha256",
    ),
    (
        "data/models/local_completion/local_completion_path_ranker_int8.onnx",
        "local_completion_model_sha256",
    ),
    (
        "data/models/local_completion/local_completion_index.bin",
        "local_completion_index_sha256",
    ),
    (
        "data/models/local_completion/local_completion_generator_int8.onnx",
        "local_completion_generator_sha256",
    ),
    (
        "data/models/local_completion/model_manifest.json",
        "local_completion_manifest_sha256",
    ),
)
LINUX_RUNTIME_ASSETS = (
    (
        "third_party/onnxruntime/linux-x86_64/libonnxruntime.so.1.20.1",
        "onnxruntime_linux_x86_64_sha256",
    ),
    (
        "third_party/onnxruntime/linux-x86_64/"
        "libonnxruntime_providers_shared.so",
        "onnxruntime_provider_linux_x86_64_sha256",
    ),
    (
        "third_party/onnxruntime/linux-aarch64/libonnxruntime.so.1.20.1",
        "onnxruntime_linux_aarch64_sha256",
    ),
    (
        "third_party/onnxruntime/linux-aarch64/"
        "libonnxruntime_providers_shared.so",
        "onnxruntime_provider_linux_aarch64_sha256",
    ),
)


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


def normalized_source_sha256(data: bytes) -> str:
    text = data.decode("utf-8-sig").replace("\r\n", "\n").replace("\r", "\n")
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def git_file(repository: Path, revision: str, path: str) -> bytes:
    return subprocess.check_output(
        ["git", "-C", str(repository), "show", f"{revision}:{path}"]
    )


def validate_reviewed_sources(
    windows_root: Path, windows_revision: str
) -> tuple[list[dict[str, object]], list[str]]:
    manifest = json.loads(SOURCE_MANIFEST_PATH.read_text(encoding="utf-8-sig"))
    if manifest.get("format") != "cassotis-reviewed-source-parity-v1":
        return [], ["unsupported reviewed source parity manifest"]

    results: list[dict[str, object]] = []
    failures: list[str] = []
    entries = manifest.get("files")
    if not isinstance(entries, list) or not entries:
        return [], ["reviewed source parity manifest has no files"]
    for entry in entries:
        path = entry.get("path") if isinstance(entry, dict) else None
        if not isinstance(path, str) or not path:
            failures.append("reviewed source parity manifest has an invalid path")
            continue
        linux_path = ROOT / path
        try:
            windows_hash = normalized_source_sha256(
                git_file(windows_root, windows_revision, path)
            )
        except (OSError, subprocess.CalledProcessError, UnicodeError):
            failures.append(f"cannot read reviewed Windows source: {path}")
            continue
        try:
            linux_hash = normalized_source_sha256(linux_path.read_bytes())
        except (OSError, UnicodeError):
            failures.append(f"cannot read reviewed Linux source: {path}")
            continue
        windows_expected = str(entry.get("windows_sha256", "")).lower()
        linux_expected = str(entry.get("linux_sha256", "")).lower()
        windows_ok = windows_hash == windows_expected
        linux_ok = linux_hash == linux_expected
        if not windows_ok:
            failures.append(f"reviewed Windows source changed: {path}")
        if not linux_ok:
            failures.append(f"reviewed Linux source changed: {path}")
        results.append(
            {
                "path": path,
                "windows_sha256": windows_hash,
                "windows_expected_sha256": windows_expected,
                "windows_ok": windows_ok,
                "linux_sha256": linux_hash,
                "linux_expected_sha256": linux_expected,
                "linux_ok": linux_ok,
            }
        )
    return results, failures


def validate_models(windows_root: Path) -> tuple[int, list[str]]:
    windows_engine = windows_root / "src" / "engine"
    linux_engine = ROOT / "src" / "engine"
    names = sorted(
        path.name
        for path in windows_engine.glob("nc_*_model.pas")
        if path.name != "nc_document_context_model.pas"
    )
    failures: list[str] = []
    if len(names) != 42:
        failures.append(f"expected 42 Windows generated models, found {len(names)}")
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

    host_models = (
        "nc_pinyin_transformer_ambiguity_gate_model.pas",
        "nc_pinyin_conditional_fusion_model.pas",
        "nc_pinyin_conditional_runtime_gate_model.pas",
        "nc_pinyin_generator_invocation_gate_model.pas",
        "nc_pinyin_generator_fusion_gate_model.pas",
    )
    for model_name in host_models:
        windows_model = windows_root / "src" / "host" / model_name
        linux_model = ROOT / "src" / "host" / model_name
        if not windows_model.is_file() or not linux_model.is_file():
            failures.append(f"missing Transformer host model: {model_name}")
        elif normalize_generated_pascal(
            windows_model
        ) != normalize_generated_pascal(linux_model):
            failures.append(f"Transformer host model differs: {model_name}")

    selector_name = "nc_local_completion_recall_selector.inc"
    windows_selector = windows_root / "src" / "host" / "native" / selector_name
    linux_selector = ROOT / "src" / "host" / "native" / selector_name
    if not windows_selector.is_file() or not linux_selector.is_file():
        failures.append(f"missing local-completion recall selector: {selector_name}")
    elif normalized_source_sha256(
        windows_selector.read_bytes()
    ) != normalized_source_sha256(linux_selector.read_bytes()):
        failures.append(f"local-completion recall selector differs: {selector_name}")
    return len(names), failures


def validate_deployed_assets(
    windows_root: Path, windows_revision: str, baseline: dict[str, str]
) -> tuple[list[dict[str, object]], list[str]]:
    results: list[dict[str, object]] = []
    failures: list[str] = []
    for path, baseline_key in DEPLOYED_MODEL_ASSETS:
        expected = baseline.get(baseline_key, "").lower()
        try:
            windows_hash = hashlib.sha256(
                git_file(windows_root, windows_revision, path)
            ).hexdigest()
        except (OSError, subprocess.CalledProcessError):
            windows_hash = ""
        try:
            linux_hash = sha256_file(ROOT / path)
        except OSError:
            linux_hash = ""
        ok = bool(expected) and windows_hash == expected and linux_hash == expected
        if not ok:
            failures.append(f"deployed model asset differs: {path}")
        results.append(
            {
                "path": path,
                "baseline_key": baseline_key,
                "sha256": linux_hash,
                "windows_sha256": windows_hash,
                "expected_sha256": expected,
                "ok": ok,
            }
        )

    runtime_version = baseline.get("onnxruntime_version", "")
    version_path = ROOT / "third_party" / "onnxruntime" / "VERSION"
    try:
        actual_version = version_path.read_text(encoding="utf-8-sig").strip()
    except OSError:
        actual_version = ""
    if not runtime_version or actual_version != runtime_version:
        failures.append("bundled ONNX Runtime version differs from baseline")
    for path, baseline_key in LINUX_RUNTIME_ASSETS:
        expected = baseline.get(baseline_key, "").lower()
        try:
            actual = sha256_file(ROOT / path)
        except OSError:
            actual = ""
        ok = bool(expected) and actual == expected
        if not ok:
            failures.append(f"bundled ONNX Runtime asset differs: {path}")
        results.append(
            {
                "path": path,
                "baseline_key": baseline_key,
                "sha256": actual,
                "expected_sha256": expected,
                "ok": ok,
            }
        )
    return results, failures


def validate_dictionary(
    path: Path,
    expected_hash: str,
    expected_schema: int,
    expected_base_rows: int,
    expected_completion_competition_rows: int,
    expected_completion_pair_audit_rows: int,
    expected_long_completion_visible_rows: int,
    expected_long_completion_recall_rows: int,
) -> dict[str, object]:
    expected_hash = expected_hash.lower()
    actual_hash = sha256_file(path)
    with closing(sqlite3.connect(
        f"file:{path.as_posix()}?mode=ro", uri=True
    )) as connection:
        row = connection.execute(
            "SELECT value FROM meta WHERE key = 'schema_version'"
        ).fetchone()
        base_rows = connection.execute(
            "SELECT COUNT(*) FROM dict_base"
        ).fetchone()[0]
        completion_competition_rows = connection.execute(
            "SELECT COUNT(*) FROM dict_base_completion_competition"
        ).fetchone()[0]
        completion_pair_audit_rows = connection.execute(
            "SELECT COUNT(*) FROM dict_base_completion_pair_audit"
        ).fetchone()[0]
        long_completion_visible_rows = connection.execute(
            "SELECT COUNT(*) FROM dict_base_long_completion"
        ).fetchone()[0]
        long_completion_recall_rows = connection.execute(
            "SELECT COUNT(*) FROM dict_base_long_completion_text"
        ).fetchone()[0]
    schema = int(row[0]) if row else -1
    return {
        "file": path.name,
        "sha256": actual_hash,
        "expected_sha256": expected_hash,
        "schema": schema,
        "expected_schema": expected_schema,
        "base_rows": base_rows,
        "expected_base_rows": expected_base_rows,
        "completion_competition_rows": completion_competition_rows,
        "expected_completion_competition_rows":
            expected_completion_competition_rows,
        "completion_pair_audit_rows": completion_pair_audit_rows,
        "expected_completion_pair_audit_rows":
            expected_completion_pair_audit_rows,
        "long_completion_visible_rows": long_completion_visible_rows,
        "expected_long_completion_visible_rows":
            expected_long_completion_visible_rows,
        "long_completion_recall_rows": long_completion_recall_rows,
        "expected_long_completion_recall_rows":
            expected_long_completion_recall_rows,
        "ok": (
            actual_hash == expected_hash
            and schema == expected_schema
            and base_rows == expected_base_rows
            and completion_competition_rows
            == expected_completion_competition_rows
            and completion_pair_audit_rows
            == expected_completion_pair_audit_rows
            and long_completion_visible_rows
            == expected_long_completion_visible_rows
            and long_completion_recall_rows
            == expected_long_completion_recall_rows
        ),
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
    deployed_assets, deployed_asset_failures = validate_deployed_assets(
        args.windows_root, baseline["reviewed_through"], baseline
    )
    failures.extend(deployed_asset_failures)
    reviewed_sources, reviewed_source_failures = validate_reviewed_sources(
        args.windows_root, baseline["reviewed_through"]
    )
    failures.extend(reviewed_source_failures)
    expected_schema = int(baseline["dictionary_schema"])
    dictionary = validate_dictionary(
        args.dictionary,
        baseline["dictionary_sha256"],
        expected_schema,
        int(baseline["dictionary_base_rows"]),
        int(baseline["dictionary_completion_competition_rows"]),
        int(baseline["dictionary_completion_pair_audit_rows"]),
        int(baseline["dictionary_long_completion_visible_rows"]),
        int(baseline["dictionary_long_completion_recall_rows"]),
    )
    if not dictionary["ok"]:
        failures.append("simplified dictionary differs from frozen baseline")
    traditional_dictionary = validate_dictionary(
        args.dictionary_traditional,
        baseline["dictionary_tc_sha256"],
        expected_schema,
        int(baseline["dictionary_tc_base_rows"]),
        int(baseline["dictionary_tc_completion_competition_rows"]),
        int(baseline["dictionary_tc_completion_pair_audit_rows"]),
        int(baseline["dictionary_tc_long_completion_visible_rows"]),
        int(baseline["dictionary_tc_long_completion_recall_rows"]),
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
        "deployed_assets": deployed_assets,
        "reviewed_production_sources": reviewed_sources,
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
