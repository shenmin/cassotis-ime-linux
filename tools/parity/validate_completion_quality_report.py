#!/usr/bin/env python3
"""Validate a full static-plus-neural completion benchmark report."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
import sys


INTEGER_FIELDS = (
    "result_timeout_ms",
    "cases",
    "opportunities",
    "prompts",
    "hits",
    "full_sentence_hits",
    "wrong_prompts",
    "saved_keys",
    "stability_pairs",
    "stable_pairs",
    "neural_requests",
    "neural_accepted",
    "neural_applied",
    "p50_ms",
    "p95_ms",
    "max_ms",
)
SIGNATURE_PATTERN = re.compile(r"^[0-9A-Fa-f]{16}$")


def parse_metrics(path: Path) -> dict[str, str]:
    metrics: dict[str, str] = {}
    for line in path.read_text(encoding="utf-8-sig").splitlines():
        if "=" not in line:
            continue
        key, value = line.split("=", 1)
        metrics[key.strip()] = value.strip()
    return metrics


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def validate_frozen_inputs(
    baseline: dict[str, str], dictionary: Path | None, cases: Path | None
) -> tuple[dict[str, dict[str, object]], list[str]]:
    inputs: dict[str, dict[str, object]] = {}
    failures: list[str] = []
    for name, path in (("dictionary", dictionary), ("cases", cases)):
        expected = baseline.get(f"metadata.{name}_sha256")
        if path is None:
            if expected:
                failures.append(
                    f"baseline binds metadata.{name}_sha256, but no input was provided"
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


def validate_invariants(metrics: dict[str, str]) -> list[str]:
    failures: list[str] = []
    if metrics.get("format") != "cassotis-completion-quality-v1":
        failures.append("unsupported or missing completion report format")
    values: dict[str, int] = {}
    for field in INTEGER_FIELDS:
        try:
            values[field] = int(metrics[field])
        except KeyError:
            failures.append(f"missing completion metric: {field}")
        except ValueError:
            failures.append(f"completion metric is not an integer: {field}")
    try:
        mean_ms = float(metrics["mean_ms"])
    except KeyError:
        failures.append("missing completion metric: mean_ms")
        mean_ms = -1.0
    except ValueError:
        failures.append("completion metric is not numeric: mean_ms")
        mean_ms = -1.0
    signature = metrics.get("completion_signature", "")
    if not SIGNATURE_PATTERN.fullmatch(signature):
        failures.append("completion_signature must be 16 hexadecimal digits")
    if failures:
        return failures

    if values["cases"] <= 0:
        failures.append("cases must be positive")
    if values["result_timeout_ms"] < 0:
        failures.append("result_timeout_ms must not be negative")
    if not 0 <= values["opportunities"] <= values["cases"]:
        failures.append("opportunities must be within the case count")
    if not 0 <= values["prompts"] <= values["opportunities"]:
        failures.append("prompts must be within the opportunity count")
    if values["hits"] < 0 or values["wrong_prompts"] < 0:
        failures.append("hit and wrong-prompt counts must not be negative")
    if values["hits"] + values["wrong_prompts"] != values["prompts"]:
        failures.append("hits plus wrong_prompts must equal prompts")
    if not 0 <= values["full_sentence_hits"] <= values["hits"]:
        failures.append("full_sentence_hits must not exceed hits")
    if values["saved_keys"] < 0:
        failures.append("saved_keys must not be negative")
    if not (
        0
        <= values["stable_pairs"]
        <= values["stability_pairs"]
        <= values["opportunities"]
    ):
        failures.append(
            "stability counts must be within the opportunity count"
        )
    if not (
        0
        <= values["neural_applied"]
        <= values["neural_accepted"]
        <= values["neural_requests"]
        <= values["opportunities"]
    ):
        failures.append("invalid neural completion pipeline counts")
    if not (
        0
        <= values["p50_ms"]
        <= values["p95_ms"]
        <= values["max_ms"]
    ):
        failures.append("completion latency percentiles are not ordered")
    if mean_ms < 0 or mean_ms > values["max_ms"]:
        failures.append("completion mean latency is outside the measured range")
    return failures


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
            failures.append(f"baseline completion metric is missing: {metric_key}")
            continue
        actual_text = metrics[metric_key]
        if comparison == "exact" and metric_key == "completion_signature":
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
            failures.append(f"completion baseline comparison is not numeric: {key}")
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


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--log", required=True, type=Path)
    parser.add_argument("--baseline", type=Path)
    parser.add_argument("--dictionary", type=Path)
    parser.add_argument("--cases", type=Path)
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()

    metrics = parse_metrics(args.log)
    failures = validate_invariants(metrics)
    baseline_metrics: dict[str, str] | None = None
    frozen_inputs: dict[str, dict[str, object]] = {}
    if args.baseline:
        baseline_metrics = parse_metrics(args.baseline)
        if baseline_metrics.get("format") != (
            "cassotis-completion-quality-baseline-v1"
        ):
            failures.append("unsupported completion baseline format")
        failures.extend(compare_baseline(metrics, baseline_metrics))
        frozen_inputs, input_failures = validate_frozen_inputs(
            baseline_metrics, args.dictionary, args.cases
        )
        failures.extend(input_failures)
    result = {
        "format": "cassotis-completion-quality-validation-v1",
        "log": str(args.log),
        "baseline": str(args.baseline) if args.baseline else None,
        "metrics": metrics,
        "baseline_metrics": baseline_metrics,
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
