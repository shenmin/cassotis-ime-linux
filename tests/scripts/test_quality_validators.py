#!/usr/bin/env python3
"""Regression checks for the shared quality/completion baseline file."""

from __future__ import annotations

import importlib.util
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


def load_module(name: str, path: Path):
    specification = importlib.util.spec_from_file_location(name, path)
    if specification is None or specification.loader is None:
        raise RuntimeError(f"cannot load validator module: {path}")
    module = importlib.util.module_from_spec(specification)
    specification.loader.exec_module(module)
    return module


quality = load_module(
    "cassotis_validate_quality_report",
    ROOT / "tools" / "parity" / "validate_quality_report.py",
)
completion = load_module(
    "cassotis_validate_neural_engine_smoke",
    ROOT / "tools" / "parity" / "validate_neural_engine_smoke.py",
)


def main() -> int:
    baseline = {
        "format": "cassotis-quality-baseline-v1",
        "metadata.long_accuracy_neural_timeout_ms": "0",
        "metadata.long_latency_neural_timeout_ms": "30",
        "long.top1_min": "100",
        "completion.cases_exact": "500",
        "completion.requests_min": "240",
        "completion.requests_max": "250",
        "completion.completion_signature_exact": "0123456789ABCDEF",
    }
    quality_failures = quality.validate_baseline(
        {
            "long.accuracy_neural_timeout_ms": "0",
            "long.latency_neural_timeout_ms": "30",
            "long.top1": "100",
        },
        baseline,
    )
    if quality_failures:
        raise AssertionError(
            "quality validator consumed completion-only metrics: "
            + repr(quality_failures)
        )

    completion_failures = completion.compare_baseline(
        {
            "cases": "500",
            "requests": "245",
            "completion_signature": "0123456789abcdef",
        },
        baseline,
    )
    if completion_failures:
        raise AssertionError(
            "completion validator rejected its baseline metrics: "
            + repr(completion_failures)
        )

    deterministic_failures = completion.validate_invariants(
        {
            "cases": "500",
            "result_timeout_ms": "0",
            "opportunities": "500",
            "requests": "247",
            "accepted": "10",
            "applied": "10",
            "visible": "10",
            "hits": "8",
            "wrong_prompts": "2",
            "saved_keys": "20",
            "completion_signature": "0123456789ABCDEF",
        }
    )
    if deterministic_failures:
        raise AssertionError(
            "completion validator rejected deterministic timeout zero: "
            + repr(deterministic_failures)
        )

    missing_completion = completion.compare_baseline(
        {"cases": "500"}, baseline
    )
    if not any("completion_signature" in item for item in missing_completion):
        raise AssertionError("completion validator did not enforce its signature")

    print("quality_validator_baseline_partition=passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
