#!/usr/bin/env python3
"""Regression checks for the shared quality/completion baseline file."""

from __future__ import annotations

from contextlib import closing
import importlib.util
import json
from pathlib import Path
import sqlite3
import tempfile


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
completion_quality = load_module(
    "cassotis_validate_completion_quality_report",
    ROOT / "tools" / "parity" / "validate_completion_quality_report.py",
)
short_completion_quality = load_module(
    "cassotis_validate_short_completion_quality_report",
    ROOT / "tools" / "parity" / "validate_short_completion_quality_report.py",
)
source_parity = load_module(
    "cassotis_validate_source_parity",
    ROOT / "tools" / "parity" / "validate_source_parity.py",
)
repeatability = load_module(
    "cassotis_validate_candidate_repeatability",
    ROOT / "tools" / "parity" / "validate_candidate_repeatability.py",
)


def test_repeatability_validator() -> None:
    row = {field: "" for field in repeatability.TEXT_FIELDS}
    row.update(case=1, query="jintiantianqibucuo", stage="no-request",
               phonetic_only=False, confidence=0.0)
    if repeatability.differences([row], [dict(row)]):
        raise AssertionError("identical traces must pass")
    changed = dict(row, top2="a different candidate")
    if repeatability.differences([row], [changed]) != [
        {"case": 1, "fields": ["top2"]}
    ]:
        raise AssertionError("candidate drift without completion drift was missed")
    with tempfile.TemporaryDirectory() as directory:
        path = Path(directory) / "trace.jsonl"
        path.write_text(json.dumps(row) + "\n", encoding="utf-8")
        if repeatability.read_trace(path, 1) != [row]:
            raise AssertionError("valid trace did not round-trip")
        for invalid in ("", json.dumps(dict(row, case=2)),
                        json.dumps(dict(row, confidence=float("nan"))),
                        json.dumps(dict(row, phonetic_only=None)),
                        json.dumps({"case": 1})):
            path.write_text(invalid, encoding="utf-8")
            try:
                repeatability.read_trace(path, 1)
            except ValueError:
                pass
            else:
                raise AssertionError("incomplete or invalid trace was accepted")


def main() -> int:
    test_repeatability_validator()
    smoke_source = (
        ROOT / "tools" / "integration" / "cassotis_neural_engine_smoke.lpr"
    ).read_text(encoding="utf-8")
    normalized_smoke_source = " ".join(smoke_source.split())
    if (
        "TncPinyinTransformerHostReranker.Create( runtime_directory, False, "
        "transformer_timeout_ms, model_threads)"
        not in normalized_smoke_source
    ):
        raise AssertionError(
            "deterministic completion smoke does not disable the conditional "
            "scorer timeout"
        )
    if (
        "TncLocalCompletionHost.Create(runtime_directory, result_timeout_ms, "
        "model_threads)"
        not in normalized_smoke_source
    ):
        raise AssertionError(
            "deterministic completion smoke does not control completion model "
            "threads"
        )
    if (
        "if result_timeout_ms = 0 then begin transformer_timeout_ms := 0; "
        "model_threads := 1; end else begin transformer_timeout_ms := "
        "c_nc_pinyin_transformer_result_timeout_ms; model_threads := 0; end"
        not in normalized_smoke_source
    ):
        raise AssertionError(
            "completion smoke does not isolate deterministic inference while "
            "retaining production defaults"
        )
    quality_source = (
        ROOT / "tools" / "benchmark" / "cassotis_quality_benchmark.lpr"
    ).read_text(encoding="utf-8")
    normalized_quality_source = " ".join(quality_source.split())
    if (
        "options.neural_runtime_path, 0, 1); accuracy_engine."
        "debug_set_search_budget_policy(sbm_deterministic, 100)"
        not in normalized_quality_source
    ):
        raise AssertionError(
            "deterministic quality benchmark does not use one inference thread"
        )

    baseline = {
        "format": "cassotis-quality-baseline-v1",
        "metadata.long_accuracy_neural_timeout_ms": "0",
        "metadata.long_accuracy_neural_threads": "1",
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
            "long.accuracy_neural_threads": "1",
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
    wrong_thread_metrics = {
        "long.accuracy_neural_timeout_ms": "0",
        "long.accuracy_neural_threads": "8",
        "long.latency_neural_timeout_ms": "30",
        "long.top1": "100",
    }
    if not quality.validate_baseline(wrong_thread_metrics, baseline):
        raise AssertionError(
            "quality validator accepted a multithreaded deterministic track"
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

    completion_quality_metrics = {
        "format": "cassotis-completion-quality-v1",
        "result_timeout_ms": "40",
        "cases": "16300",
        "opportunities": "16300",
        "prompts": "3834",
        "hits": "202",
        "full_sentence_hits": "10",
        "wrong_prompts": "3632",
        "saved_keys": "571",
        "stability_pairs": "100",
        "stable_pairs": "95",
        "neural_requests": "8000",
        "neural_accepted": "900",
        "neural_applied": "900",
        "completion_signature": "0123456789ABCDEF",
        "mean_ms": "20.500",
        "p50_ms": "18",
        "p95_ms": "40",
        "max_ms": "100",
    }
    full_completion_failures = completion_quality.validate_invariants(
        completion_quality_metrics
    )
    if full_completion_failures:
        raise AssertionError(
            "full completion validator rejected valid metrics: "
            + repr(full_completion_failures)
        )
    full_completion_baseline = {
        "format": "cassotis-completion-quality-baseline-v1",
        "result_timeout_ms_exact": "40",
        "cases_exact": "16300",
        "prompts_min": "3800",
        "hits_min": "200",
        "mean_ms_max": "25",
        "p95_ms_max": "50",
    }
    baseline_failures = completion_quality.compare_baseline(
        completion_quality_metrics, full_completion_baseline
    )
    if baseline_failures:
        raise AssertionError(
            "full completion validator rejected valid release floors: "
            + repr(baseline_failures)
        )
    regressed_completion = dict(completion_quality_metrics)
    regressed_completion["hits"] = "199"
    regressed_completion["wrong_prompts"] = "3635"
    if not completion_quality.compare_baseline(
        regressed_completion, full_completion_baseline
    ):
        raise AssertionError("full completion validator missed a quality regression")
    slow_completion = dict(completion_quality_metrics)
    slow_completion["p95_ms"] = "51"
    if not completion_quality.compare_baseline(
        slow_completion, full_completion_baseline
    ):
        raise AssertionError("full completion validator missed a latency regression")
    invalid_completion = dict(completion_quality_metrics)
    invalid_completion["wrong_prompts"] = "1"
    if not completion_quality.validate_invariants(invalid_completion):
        raise AssertionError("full completion validator missed invalid counts")
    invalid_completion = dict(completion_quality_metrics)
    invalid_completion["prompts"] = "16301"
    invalid_completion["wrong_prompts"] = "16099"
    if not completion_quality.validate_invariants(invalid_completion):
        raise AssertionError(
            "full completion validator allowed prompts beyond opportunities"
        )

    arm_completion_baseline = completion_quality.parse_metrics(
        ROOT / "tests" / "baselines" /
        "completion-quality-v1.21.0-linux-aarch64.txt"
    )
    for counter in ("neural_accepted", "neural_applied"):
        if counter + "_max" in arm_completion_baseline:
            raise AssertionError("pipeline throughput must not have a fixed cap")
    arm_completion_metrics = dict(
        completion_quality_metrics, prompts="6200", hits="350",
        full_sentence_hits="20", wrong_prompts="5850", saved_keys="820",
        stability_pairs="650", stable_pairs="20", neural_requests="8300",
        neural_accepted="4000", neural_applied="3900",
    )
    for accepted, applied in ((2900, 2900), (4000, 3900), (8300, 6200)):
        higher_throughput = dict(arm_completion_metrics,
                                 neural_accepted=str(accepted),
                                 neural_applied=str(applied))
        failures = completion_quality.validate_invariants(higher_throughput)
        failures += completion_quality.compare_baseline(
            higher_throughput, arm_completion_baseline
        )
        if failures:
            raise AssertionError("valid completion throughput was rejected: "
                                 + repr(failures))
    for accepted, applied in ((8301, 3900), (4000, 4001), (-1, -1)):
        invalid_pipeline = dict(arm_completion_metrics,
                                neural_accepted=str(accepted),
                                neural_applied=str(applied))
        if not completion_quality.validate_invariants(invalid_pipeline):
            raise AssertionError("invalid completion pipeline counts were accepted")
    for metric, value in (("hits", "339"), ("wrong_prompts", "6201"),
                          ("saved_keys", "809"), ("p95_ms", "131"),
                          ("result_timeout_ms", "41")):
        regressed = dict(arm_completion_metrics)
        regressed[metric] = value
        failures = completion_quality.compare_baseline(
            regressed, arm_completion_baseline
        )
        if not any(item.startswith(metric + "=") for item in failures):
            raise AssertionError("completion constraint was not enforced: " + metric)

    short_completion_metrics = {
        "format": "cassotis-short-completion-quality-v1",
        "cases": "65000",
        "opportunities": "12831",
        "prompts": "12775",
        "hits": "9420",
        "wrong_prompts": "3355",
        "saved_keys": "24006",
        "average_saved_keys": "2.548",
        "stability_pairs": "1749",
        "stable_pairs": "1691",
        "completion_signature": "D33AC07C1551CAA1",
        "mean_ms": "1.241",
        "p50_ms": "1",
        "p95_ms": "3",
        "max_ms": "51",
    }
    short_invariant_failures = short_completion_quality.validate_invariants(
        short_completion_metrics
    )
    if short_invariant_failures:
        raise AssertionError(
            "short completion validator rejected valid metrics: "
            + repr(short_invariant_failures)
        )
    short_completion_baseline = {
        "format": "cassotis-short-completion-quality-baseline-v1",
        "cases_exact": "65000",
        "opportunities_exact": "12831",
        "hits_min": "9420",
        "completion_signature_exact": "D33AC07C1551CAA1",
        "p95_ms_max": "10",
    }
    short_baseline_failures = short_completion_quality.compare_baseline(
        short_completion_metrics, short_completion_baseline
    )
    if short_baseline_failures:
        raise AssertionError(
            "short completion validator rejected valid release floors: "
            + repr(short_baseline_failures)
        )
    short_signature_drift = dict(short_completion_metrics)
    short_signature_drift["completion_signature"] = "0123456789ABCDEF"
    if not short_completion_quality.compare_baseline(
        short_signature_drift, short_completion_baseline
    ):
        raise AssertionError(
            "short completion validator missed visible-result drift"
        )
    invalid_short_completion = dict(short_completion_metrics)
    invalid_short_completion["wrong_prompts"] = "3354"
    if not short_completion_quality.validate_invariants(
        invalid_short_completion
    ):
        raise AssertionError(
            "short completion validator missed invalid prompt counts"
        )

    with tempfile.TemporaryDirectory() as temporary_directory:
        frozen_dictionary_path = Path(temporary_directory) / "frozen.db"
        frozen_cases_path = Path(temporary_directory) / "frozen.tsv"
        frozen_dictionary_path.write_bytes(b"dictionary")
        frozen_cases_path.write_bytes(b"cases")
        frozen_baseline = {
            "metadata.dictionary_sha256": completion_quality.sha256_file(
                frozen_dictionary_path
            ),
            "metadata.cases_sha256": completion_quality.sha256_file(
                frozen_cases_path
            ),
        }
        _, frozen_failures = completion_quality.validate_frozen_inputs(
            frozen_baseline, frozen_dictionary_path, frozen_cases_path
        )
        if frozen_failures:
            raise AssertionError(
                "full completion validator rejected frozen inputs: "
                + repr(frozen_failures)
            )
        frozen_cases_path.write_bytes(b"changed")
        _, frozen_failures = completion_quality.validate_frozen_inputs(
            frozen_baseline, frozen_dictionary_path, frozen_cases_path
        )
        if not any("cases sha256" in item for item in frozen_failures):
            raise AssertionError("full completion validator missed input drift")

        short_frozen_baseline = {
            "metadata.dictionary_sha256": short_completion_quality.sha256_file(
                frozen_dictionary_path
            ),
            "metadata.cases_sha256": short_completion_quality.sha256_file(
                frozen_cases_path
            ),
        }
        _, short_frozen_failures = (
            short_completion_quality.validate_frozen_inputs(
                short_frozen_baseline,
                frozen_dictionary_path,
                frozen_cases_path,
            )
        )
        if short_frozen_failures:
            raise AssertionError(
                "short completion validator rejected frozen inputs: "
                + repr(short_frozen_failures)
            )
        frozen_dictionary_path.write_bytes(b"changed dictionary")
        _, short_frozen_failures = (
            short_completion_quality.validate_frozen_inputs(
                short_frozen_baseline,
                frozen_dictionary_path,
                frozen_cases_path,
            )
        )
        if not any(
            "dictionary sha256" in item for item in short_frozen_failures
        ):
            raise AssertionError(
                "short completion validator missed input drift"
            )

        dictionary_path = Path(temporary_directory) / "dictionary.db"
        with closing(sqlite3.connect(dictionary_path)) as connection:
            connection.executescript(
                """
                CREATE TABLE meta(key TEXT PRIMARY KEY, value TEXT);
                INSERT INTO meta VALUES('schema_version', '24');
                CREATE TABLE dict_base(value INTEGER);
                CREATE TABLE dict_base_completion_competition(value INTEGER);
                CREATE TABLE dict_base_completion_pair_audit(value INTEGER);
                CREATE TABLE dict_base_long_completion(value INTEGER);
                CREATE TABLE dict_base_long_completion_text(value INTEGER);
                """
            )
            for table_name, count in (
                ("dict_base", 3),
                ("dict_base_completion_competition", 2),
                ("dict_base_completion_pair_audit", 1),
                ("dict_base_long_completion", 4),
                ("dict_base_long_completion_text", 5),
            ):
                connection.executemany(
                    f"INSERT INTO {table_name} VALUES(?)",
                    ((index,) for index in range(count)),
                )
            connection.commit()
        dictionary_result = source_parity.validate_dictionary(
            dictionary_path,
            source_parity.sha256_file(dictionary_path),
            24,
            3,
            2,
            1,
            4,
            5,
        )
        if not dictionary_result["ok"]:
            raise AssertionError("source parity rejected complete dictionary rows")
        with closing(sqlite3.connect(dictionary_path)) as connection:
            connection.execute(
                "DELETE FROM dict_base_completion_competition WHERE value = 0"
            )
            connection.commit()
        dictionary_result = source_parity.validate_dictionary(
            dictionary_path,
            source_parity.sha256_file(dictionary_path),
            24,
            3,
            2,
            1,
            4,
            5,
        )
        if dictionary_result["ok"]:
            raise AssertionError("source parity missed a completion-row deficit")

    print("quality_validator_baseline_partition=passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
