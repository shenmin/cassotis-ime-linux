#!/usr/bin/env python3
"""Validate the real-engine neural completion smoke report."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import re
import sys


INTEGER_FIELDS = (
    "cases",
    "result_timeout_ms",
    "opportunities",
    "requests",
    "accepted",
    "applied",
    "visible",
    "hits",
    "wrong_prompts",
    "saved_keys",
)
SIGNATURE_PATTERN = re.compile(r"^[0-9A-Fa-f]{16}$")


def parse_metrics(path: Path) -> dict[str, str]:
    metrics: dict[str, str] = {}
    for raw_line in path.read_text(encoding="utf-8-sig").splitlines():
        key, separator, value = raw_line.partition("=")
        if separator and key.strip():
            metrics[key.strip()] = value.strip()
    return metrics


def validate_invariants(metrics: dict[str, str]) -> list[str]:
    failures: list[str] = []
    values: dict[str, int] = {}
    for field in INTEGER_FIELDS:
        try:
            values[field] = int(metrics[field])
        except KeyError:
            failures.append(f"missing smoke metric: {field}")
        except ValueError:
            failures.append(f"smoke metric is not an integer: {field}")
    signature = metrics.get("completion_signature", "")
    if not SIGNATURE_PATTERN.fullmatch(signature):
        failures.append("completion_signature must be 16 hexadecimal digits")
    if failures:
        return failures

    if values["cases"] <= 0:
        failures.append("cases must be positive")
    if values["result_timeout_ms"] < 0:
        failures.append("result_timeout_ms must not be negative")
    if not (
        0
        <= values["visible"]
        <= values["applied"]
        <= values["accepted"]
        <= values["requests"]
        <= values["opportunities"]
        <= values["cases"]
    ):
        failures.append("invalid neural completion pipeline counts")
    if values["hits"] + values["wrong_prompts"] != values["visible"]:
        failures.append("hits plus wrong_prompts must equal visible")
    if values["saved_keys"] < 0:
        failures.append("saved_keys must not be negative")
    if min(
        values["requests"], values["accepted"], values["applied"],
        values["visible"]
    ) <= 0:
        failures.append("real neural completion path was not exercised")
    return failures


def compare_baseline(
    metrics: dict[str, str], baseline: dict[str, str]
) -> list[str]:
    failures: list[str] = []
    for key, expected_text in baseline.items():
        if not key.startswith("completion."):
            continue
        comparison = "exact"
        metric_key = key[len("completion."):]
        for suffix, candidate in (
            ("_min", "minimum"),
            ("_max", "maximum"),
            ("_exact", "exact"),
        ):
            if metric_key.endswith(suffix):
                metric_key = metric_key[:-len(suffix)]
                comparison = candidate
                break
        if metric_key not in metrics:
            failures.append(f"baseline smoke metric is missing: {metric_key}")
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
            failures.append(f"smoke baseline comparison is not numeric: {key}")
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
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()

    metrics = parse_metrics(args.log)
    failures = validate_invariants(metrics)
    if args.baseline:
        failures.extend(compare_baseline(metrics, parse_metrics(args.baseline)))
    result = {
        "format": "cassotis-neural-engine-smoke-validation-v1",
        "log": str(args.log),
        "baseline": str(args.baseline) if args.baseline else None,
        "metrics": metrics,
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
