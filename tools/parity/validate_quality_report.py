#!/usr/bin/env python3
"""Validate completeness and invariants of a Linux quality benchmark report."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import sys


def parse_metrics(path: Path) -> dict[str, str]:
    metrics: dict[str, str] = {}
    for raw_line in path.read_text(encoding="utf-8-sig").splitlines():
        if not raw_line.strip():
            continue
        key, separator, value = raw_line.partition("=")
        if not separator:
            raise ValueError(f"invalid metric line: {raw_line!r}")
        metrics[key.strip()] = value.strip()
    return metrics


def case_count(path: Path) -> int:
    with path.open("r", encoding="utf-8-sig") as stream:
        return sum(1 for line_number, line in enumerate(stream) if line_number and line.strip())


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def failure_signature(
    path: Path, expected_header: tuple[str, ...]
) -> tuple[dict[str, object], list[str]]:
    failures: list[str] = []
    try:
        lines = path.read_text(encoding="utf-8-sig").splitlines()
    except OSError as error:
        return {}, [f"cannot read benchmark failure report {path}: {error}"]
    if not lines:
        return {}, [f"benchmark failure report is empty: {path}"]

    header = tuple(lines[0].split("\t"))
    if header != expected_header:
        failures.append(
            f"unexpected benchmark failure header in {path}: {header!r}"
        )

    stable_lines: list[str] = []
    expected_columns = len(expected_header)
    for line_number, line in enumerate(lines, start=1):
        fields = line.split("\t")
        if len(fields) != expected_columns:
            failures.append(
                f"invalid column count in {path} at line {line_number}"
            )
            continue
        # Latency is host-dependent. Every other field identifies the exact
        # case and ranking result and therefore forms a deterministic gate.
        stable_lines.append("\t".join(fields[:-1]))
    rendered = ("\n".join(stable_lines) + "\n").encode("utf-8")
    return {
        "path": str(path),
        "rows": max(0, len(lines) - 1),
        "sha256": hashlib.sha256(rendered).hexdigest(),
    }, failures


def validate_failure_signatures(
    summary: Path, metrics: dict[str, str], baseline: dict[str, str]
) -> tuple[dict[str, dict[str, object]], list[str]]:
    signatures: dict[str, dict[str, object]] = {}
    failures: list[str] = []
    specifications = {
        "long": (
            summary.parent / "long-failures.tsv",
            ("index", "expected", "pinyin", "rank", "top1", "latency_ms"),
            ("long",),
        ),
        "short": (
            summary.parent / "short-failures.tsv",
            ("index", "mode", "expected", "pinyin", "rank", "top1", "latency_ms"),
            ("short.off", "short.on"),
        ),
    }
    for name, (path, header, tracks) in specifications.items():
        expected_hash = baseline.get(f"signature.{name}.sha256")
        expected_rows = baseline.get(f"signature.{name}.rows_exact")
        if not expected_hash and expected_rows is None:
            continue
        signature, signature_failures = failure_signature(path, header)
        failures.extend(signature_failures)
        if not signature:
            continue
        signatures[name] = signature
        if expected_hash and signature["sha256"].lower() != expected_hash.lower():
            failures.append(
                f"{name} failure signature {signature['sha256']} does not match "
                f"frozen baseline {expected_hash}"
            )
        if expected_rows is not None:
            try:
                row_count = int(expected_rows)
            except ValueError:
                failures.append(
                    f"signature.{name}.rows_exact is not an integer"
                )
            else:
                if signature["rows"] != row_count:
                    failures.append(
                        f"{name} failure rows={signature['rows']} but expected "
                        f"{row_count}"
                    )

        expected_from_metrics = 0
        try:
            for track in tracks:
                expected_from_metrics += (
                    int(metrics[f"{track}.total"]) - int(metrics[f"{track}.top1"])
                )
        except (KeyError, ValueError):
            pass
        else:
            if signature["rows"] != expected_from_metrics:
                failures.append(
                    f"{name} failure rows={signature['rows']} but summary requires "
                    f"{expected_from_metrics}"
                )
    return signatures, failures


def validate_frozen_inputs(
    baseline: dict[str, str], dictionary: Path | None,
    long_cases: Path | None, short_cases: Path | None
) -> tuple[dict[str, dict[str, object]], list[str]]:
    inputs: dict[str, dict[str, object]] = {}
    failures: list[str] = []
    for name, path in (
        ("dictionary", dictionary),
        ("long_cases", long_cases),
        ("short_cases", short_cases),
    ):
        metadata_key = f"metadata.{name}_sha256"
        expected = baseline.get(metadata_key)
        if path is None:
            if expected:
                failures.append(
                    f"baseline binds {metadata_key}, but the input was not provided"
                )
            continue
        actual = sha256_file(path)
        inputs[name] = {
            "path": str(path),
            "bytes": path.stat().st_size,
            "sha256": actual,
        }
        if expected and actual.lower() != expected.lower():
            failures.append(
                f"{name} sha256={actual} does not match frozen baseline {expected}"
            )
    return inputs, failures


def validate_track(
    metrics: dict[str, str], prefix: str, expected_total: int
) -> list[str]:
    failures: list[str] = []
    integer_keys = ["total", "top1", "top2", "top5", "top9", "p50_ms", "p95_ms", "max_ms"]
    values: dict[str, int] = {}
    for suffix in integer_keys:
        key = f"{prefix}.{suffix}"
        try:
            values[suffix] = int(metrics[key])
        except KeyError:
            failures.append(f"missing metric: {key}")
        except ValueError:
            failures.append(f"metric is not an integer: {key}")
    if failures:
        return failures
    if values["total"] != expected_total:
        failures.append(
            f"{prefix}.total={values['total']} but expected {expected_total}"
        )
    if not 0 <= values["top1"] <= values["top2"] <= values["top5"] <= values["top9"] <= values["total"]:
        failures.append(f"invalid ranking count order for {prefix}")
    if not 0 <= values["p50_ms"] <= values["p95_ms"] <= values["max_ms"]:
        failures.append(f"invalid latency percentile order for {prefix}")
    mean_key = f"{prefix}.mean_ms"
    try:
        mean_value = float(metrics[mean_key])
        if mean_value < 0:
            failures.append(f"negative mean latency: {mean_key}")
    except KeyError:
        failures.append(f"missing metric: {mean_key}")
    except ValueError:
        failures.append(f"metric is not numeric: {mean_key}")
    return failures


def validate_baseline(
    metrics: dict[str, str], baseline: dict[str, str]
) -> list[str]:
    failures: list[str] = []
    if baseline.get("format") != "cassotis-quality-baseline-v1":
        return ["unsupported or missing quality baseline format"]

    for metadata_key, metric_key in (
        ("metadata.long_neural_runtime", "long.neural_runtime"),
        ("metadata.long_accuracy_mode", "long.accuracy_mode"),
        (
            "metadata.long_accuracy_neural_timeout_ms",
            "long.accuracy_neural_timeout_ms",
        ),
        (
            "metadata.long_accuracy_neural_threads",
            "long.accuracy_neural_threads",
        ),
        ("metadata.long_latency_mode", "long.latency_mode"),
        (
            "metadata.long_latency_neural_timeout_ms",
            "long.latency_neural_timeout_ms",
        ),
    ):
        expected_value = baseline.get(metadata_key)
        if expected_value is not None and metrics.get(metric_key) != expected_value:
            failures.append(
                f"{metric_key}={metrics.get(metric_key, '<missing>')} does not "
                f"match frozen baseline {expected_value}"
            )

    for key, raw_value in baseline.items():
        if (key == "format" or key.startswith("metadata.") or
                key.startswith("signature.") or
                key.startswith("completion.")):
            continue
        metric_key = key
        comparison = "exact"
        for suffix, candidate in (
            ("_min", "minimum"),
            ("_max", "maximum"),
            ("_exact", "exact"),
        ):
            if key.endswith(suffix):
                metric_key = key[: -len(suffix)]
                comparison = candidate
                break
        if metric_key not in metrics:
            failures.append(f"baseline metric is missing from report: {metric_key}")
            continue
        try:
            expected = float(raw_value)
            actual = float(metrics[metric_key])
        except ValueError:
            failures.append(f"baseline comparison is not numeric: {key}")
            continue
        if comparison == "minimum" and actual < expected:
            failures.append(
                f"{metric_key}={metrics[metric_key]} is below baseline {raw_value}"
            )
        elif comparison == "maximum" and actual > expected:
            failures.append(
                f"{metric_key}={metrics[metric_key]} exceeds baseline {raw_value}"
            )
        elif comparison == "exact" and actual != expected:
            failures.append(
                f"{metric_key}={metrics[metric_key]} does not equal baseline {raw_value}"
            )
    return failures


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--summary", required=True, type=Path)
    parser.add_argument("--dictionary", type=Path)
    parser.add_argument("--long-cases", type=Path)
    parser.add_argument("--short-cases", type=Path)
    parser.add_argument("--baseline", type=Path)
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()

    metrics = parse_metrics(args.summary)
    failures: list[str] = []
    if metrics.get("format") != "cassotis-quality-v1":
        failures.append("unsupported or missing quality report format")
    tracks: dict[str, int] = {}
    if args.long_cases:
        tracks["long"] = case_count(args.long_cases)
    if args.short_cases:
        short_total = case_count(args.short_cases)
        tracks["short.off"] = short_total
        tracks["short.on"] = short_total
    if not tracks:
        failures.append("at least one case file is required")
    for prefix, expected_total in tracks.items():
        failures.extend(validate_track(metrics, prefix, expected_total))

    baseline_metrics: dict[str, str] | None = None
    frozen_inputs: dict[str, dict[str, object]] = {}
    result_signatures: dict[str, dict[str, object]] = {}
    if args.baseline:
        baseline_metrics = parse_metrics(args.baseline)
        failures.extend(validate_baseline(metrics, baseline_metrics))
        frozen_inputs, input_failures = validate_frozen_inputs(
            baseline_metrics, args.dictionary, args.long_cases, args.short_cases
        )
        failures.extend(input_failures)
        result_signatures, signature_failures = validate_failure_signatures(
            args.summary, metrics, baseline_metrics
        )
        failures.extend(signature_failures)

    result = {
        "format": "cassotis-quality-validation-v1",
        "summary": str(args.summary),
        "tracks": tracks,
        "metrics": metrics,
        "baseline": str(args.baseline) if args.baseline else None,
        "baseline_metrics": baseline_metrics,
        "frozen_inputs": frozen_inputs,
        "result_signatures": result_signatures,
        "failures": failures,
        "ok": not failures,
    }
    rendered = json.dumps(result, ensure_ascii=False, indent=2) + "\n"
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(rendered, encoding="utf-8")
    sys.stdout.write(rendered)
    return 0 if result["ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
