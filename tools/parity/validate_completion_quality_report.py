#!/usr/bin/env python3
"""Validate a full static-plus-neural completion benchmark report."""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import math
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
LATENCY_SCOPE = "decode_final_candidates_visible_completion_v1"


def parse_metrics(path: Path) -> dict[str, str]:
    metrics: dict[str, str] = {}
    for line in path.read_text(encoding="utf-8-sig").splitlines():
        if line.lstrip().startswith("#") or "=" not in line:
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
    if not math.isfinite(mean_ms) or mean_ms < 0 or mean_ms > values["max_ms"]:
        failures.append("completion mean latency is outside the measured range")
    if "latency_scope" in metrics:
        if metrics["latency_scope"] != LATENCY_SCOPE:
            failures.append("unsupported completion latency scope")
        try:
            phases = [float(metrics[field]) for field in (
                "decode_mean_ms", "final_candidates_mean_ms", "completion_mean_ms"
            )]
        except (KeyError, ValueError):
            failures.append("missing or invalid completion latency phases")
        else:
            if any(not math.isfinite(value) or value < 0 for value in phases):
                failures.append("completion latency phases must be finite and nonnegative")
            elif not math.isclose(sum(phases), mean_ms, rel_tol=0, abs_tol=0.01):
                failures.append("completion latency phases do not sum to mean_ms")
    return failures


def compare_baseline(
    metrics: dict[str, str], baseline: dict[str, str]
) -> list[str]:
    failures: list[str] = []
    metrics = dict(metrics)
    # Keep the earlier decode-plus-completion mean budget independently of
    # the newly measured final-candidate readback/repair phase.
    if metrics.get("latency_scope") == LATENCY_SCOPE and \
            "decode_and_completion_mean_ms" not in metrics:
        try:
            earlier_phases = (
                float(metrics["decode_mean_ms"]),
                float(metrics["completion_mean_ms"]),
            )
        except (KeyError, ValueError):
            pass
        else:
            if all(math.isfinite(value) and value >= 0 for value in earlier_phases):
                metrics["decode_and_completion_mean_ms"] = str(sum(earlier_phases))
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
        if comparison == "exact" and metric_key in ("completion_signature", "latency_scope"):
            if actual_text.lower() != expected_text.lower():
                failures.append(
                    f"{metric_key}={actual_text} does not equal "
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


def validate_trace(
    path: Path, metrics: dict[str, str], cases_path: Path | None = None
) -> tuple[dict[str, str], list[str]]:
    """Bind aggregate results and both latency budgets to measured samples."""
    failures: list[str] = []
    derived: dict[str, str] = {}
    try:
        with path.open(encoding="utf-8-sig", newline="") as stream:
            rows = list(csv.DictReader(stream, delimiter="\t"))
        cases = None
        if cases_path is not None:
            with cases_path.open(encoding="utf-8-sig", newline="") as stream:
                reader = csv.reader(stream, delimiter="\t")
                next(reader)
                cases = [row for row in reader if row]
        totals = dict.fromkeys(("prompts", "hits", "full_sentence_hits",
                               "wrong_prompts", "saved_keys", "neural_requests",
                               "neural_accepted", "neural_applied"), 0)
        samples: dict[str, list[int]] = {
            "": [], "decode_": [], "final_candidates_": [],
            "completion_": [], "decode_and_completion_": [],
        }
        signature = 14695981039346656037
        previous_index = 0
        for opportunity, row in enumerate(rows, 1):
            index = int(row["index"])
            if not previous_index < index <= int(metrics["cases"]):
                raise ValueError("trace case indexes are duplicated or out of order")
            previous_index = index
            if cases is not None and (
                index > len(cases) or cases[index - 1][3:5] !=
                    [row["expected"], row["pinyin"]]
            ):
                raise ValueError(f"trace case {index} differs from the frozen input")
            flags = [int(row[key]) for key in ("request", "accepted", "applied", "hit")]
            request, accepted, applied, hit = flags
            if any(value not in (0, 1) for value in flags) or not applied <= accepted <= request:
                raise ValueError(f"trace case {index} has invalid pipeline flags")
            text = row["completion"].strip().casefold()
            target = row["target_prefix"].casefold()
            expected = row["expected"].strip().casefold()
            actual_hit = bool(text) and len(text) > len(target) and \
                text.startswith(target) and expected.startswith(text)
            if hit != int(actual_hit):
                raise ValueError(f"trace case {index} has an inconsistent hit flag")
            saved = max(0, len(row["full_pinyin"].replace("'", "")) -
                        len(row["typed_prefix"]) - 1) if hit else 0
            if int(row["saved_keys"]) != saved:
                raise ValueError(f"trace case {index} has inconsistent key savings")
            totals["prompts"] += bool(text)
            totals["hits"] += hit
            totals["full_sentence_hits"] += bool(text) and text == expected
            totals["wrong_prompts"] += bool(text) and not hit
            totals["saved_keys"] += saved
            totals["neural_requests"] += request
            totals["neural_accepted"] += accepted
            totals["neural_applied"] += applied
            total, decode, final = [int(row[key]) for key in (
                "latency_ms", "decode_ms", "final_candidates_ms")]
            completion = total - decode - final
            if min(total, decode, final, completion) < 0:
                raise ValueError(f"trace case {index} has invalid latency phases")
            for name, value in (("", total), ("decode_", decode),
                                ("final_candidates_", final), ("completion_", completion),
                                ("decode_and_completion_", total - final)):
                samples[name].append(value)
            payload = f"{opportunity}\t{row['completion']}\t{row['full_pinyin']}\t{hit}\n"
            for byte in payload.encode("utf-8"):
                signature = ((signature ^ byte) * 1099511628211) & ((1 << 64) - 1)
        if len(rows) != int(metrics["opportunities"]):
            failures.append("completion trace does not cover every opportunity")
        for key, value in totals.items():
            if value != int(metrics[key]):
                failures.append(f"completion trace {key} differs from the summary")
        if f"{signature:016X}" != metrics["completion_signature"].upper():
            failures.append("completion trace signature differs from the summary")
        for prefix, values in samples.items():
            values.sort()
            derived[prefix + "mean_ms"] = f"{sum(values) / len(values) if values else 0:.3f}"
            for name, quantile in (("p50_ms", 0.50), ("p95_ms", 0.95), ("max_ms", 1)):
                derived[prefix + name] = str(values[math.ceil(len(values) * quantile) - 1]
                                             if values else 0)
        for key, value in derived.items():
            if key in metrics and not math.isclose(float(value), float(metrics[key]),
                                                    rel_tol=0, abs_tol=0.002):
                failures.append(f"completion trace {key} differs from the summary")
    except (OSError, KeyError, ValueError, TypeError, IndexError, StopIteration) as error:
        failures.append(f"invalid completion trace: {error}")
    return derived, failures


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--log", required=True, type=Path)
    parser.add_argument("--baseline", type=Path)
    parser.add_argument("--dictionary", type=Path)
    parser.add_argument("--cases", type=Path)
    parser.add_argument("--trace", type=Path)
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()

    metrics = parse_metrics(args.log)
    failures = validate_invariants(metrics)
    trace_metrics: dict[str, str] = {}
    if args.trace:
        trace_metrics, trace_failures = validate_trace(args.trace, metrics, args.cases)
        failures.extend(trace_failures)
    baseline_metrics: dict[str, str] | None = None
    frozen_inputs: dict[str, dict[str, object]] = {}
    if args.baseline:
        baseline_metrics = parse_metrics(args.baseline)
        if baseline_metrics.get("format") != (
            "cassotis-completion-quality-baseline-v1"
        ):
            failures.append("unsupported completion baseline format")
        if baseline_metrics.get("metadata.trace_required") == "true" and not args.trace:
            failures.append("baseline requires a per-case completion trace")
        failures.extend(compare_baseline(dict(metrics, **trace_metrics), baseline_metrics))
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
        "trace": str(args.trace) if args.trace else None,
        "trace_sha256": sha256_file(args.trace) if args.trace and args.trace.is_file() else None,
        "trace_metrics": trace_metrics,
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
