#!/usr/bin/env python3
"""Validate the fixed short-word one-key-completion benchmark."""

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


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def validate_frozen_inputs(
    baseline: dict[str, str], dictionary: Path, cases: Path
) -> tuple[dict[str, dict[str, object]], list[str]]:
    inputs: dict[str, dict[str, object]] = {}
    failures: list[str] = []
    for name, path in (("dictionary", dictionary), ("cases", cases)):
        actual = sha256_file(path)
        inputs[name] = {
            "path": str(path),
            "bytes": path.stat().st_size,
            "sha256": actual,
        }
        expected = baseline.get(f"metadata.{name}_sha256")
        if expected and actual.lower() != expected.lower():
            failures.append(
                f"{name} sha256={actual} does not match {expected}"
            )
    return inputs, failures


def compare_baseline(
    metrics: dict[str, str], baseline: dict[str, str]
) -> list[str]:
    failures: list[str] = []
    for key, expected_text in baseline.items():
        if key == "format" or key.startswith("metadata."):
            continue
        comparison = "exact"
        metric_key = key
        for suffix, candidate in (
            ("_min", "minimum"),
            ("_max", "maximum"),
            ("_exact", "exact"),
        ):
            if metric_key.endswith(suffix):
                metric_key = metric_key[: -len(suffix)]
                comparison = candidate
                break
        if metric_key not in metrics:
            failures.append(f"short completion metric is missing: {metric_key}")
            continue
        actual_text = metrics[metric_key]
        if metric_key == "completion_signature" and comparison == "exact":
            if actual_text.lower() != expected_text.lower():
                failures.append(
                    f"completion_signature={actual_text} does not equal "
                    f"baseline {expected_text}"
                )
            continue
        try:
            actual = float(actual_text)
            expected = float(expected_text)
        except ValueError:
            failures.append(f"short completion comparison is not numeric: {key}")
            continue
        if comparison == "minimum" and actual < expected:
            failures.append(
                f"{metric_key}={actual_text} is below baseline {expected_text}"
            )
        elif comparison == "maximum" and actual > expected:
            failures.append(
                f"{metric_key}={actual_text} exceeds baseline {expected_text}"
            )
        elif comparison == "exact" and actual != expected:
            failures.append(
                f"{metric_key}={actual_text} does not equal baseline {expected_text}"
            )
    return failures


def validate_invariants(metrics: dict[str, str]) -> list[str]:
    failures: list[str] = []
    integer_keys = (
        "cases",
        "opportunities",
        "prompts",
        "hits",
        "wrong_prompts",
        "saved_keys",
        "stability_pairs",
        "stable_pairs",
        "p50_ms",
        "p95_ms",
        "max_ms",
    )
    values: dict[str, int] = {}
    for key in integer_keys:
        try:
            values[key] = int(metrics[key])
        except KeyError:
            failures.append(f"missing metric: {key}")
        except ValueError:
            failures.append(f"metric is not an integer: {key}")
    if failures:
        return failures
    if not 0 <= values["hits"] <= values["prompts"] <= values["opportunities"]:
        failures.append("invalid short completion hit/prompt counts")
    if values["wrong_prompts"] != values["prompts"] - values["hits"]:
        failures.append("wrong prompt count does not match prompt minus hit")
    if not 0 <= values["stable_pairs"] <= values["stability_pairs"]:
        failures.append("invalid short completion stability counts")
    if not 0 <= values["p50_ms"] <= values["p95_ms"] <= values["max_ms"]:
        failures.append("short completion latency percentiles are not ordered")
    try:
        mean_ms = float(metrics["mean_ms"])
        average_saved = float(metrics["average_saved_keys"])
    except (KeyError, ValueError):
        failures.append("short completion floating-point metric is missing")
    else:
        if not 0 <= mean_ms <= values["max_ms"]:
            failures.append("short completion mean latency is invalid")
        if average_saved < 0:
            failures.append("short completion average saved keys is negative")
    return failures


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--log", required=True, type=Path)
    parser.add_argument("--baseline", required=True, type=Path)
    parser.add_argument("--dictionary", required=True, type=Path)
    parser.add_argument("--cases", required=True, type=Path)
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()

    metrics = parse_metrics(args.log)
    baseline = parse_metrics(args.baseline)
    failures: list[str] = []
    if metrics.get("format") != "cassotis-short-completion-quality-v1":
        failures.append("unsupported short completion report format")
    if baseline.get("format") != "cassotis-short-completion-quality-baseline-v1":
        failures.append("unsupported short completion baseline format")
    failures.extend(validate_invariants(metrics))
    failures.extend(compare_baseline(metrics, baseline))

    frozen_inputs, input_failures = validate_frozen_inputs(
        baseline, args.dictionary, args.cases
    )
    failures.extend(input_failures)

    result = {
        "format": "cassotis-short-completion-quality-validation-v1",
        "log": str(args.log),
        "baseline": str(args.baseline),
        "metrics": metrics,
        "baseline_metrics": baseline,
        "frozen_inputs": frozen_inputs,
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
