#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/common.sh"

dictionary_path=''
traditional_dictionary_path=''
long_cases=''
short_cases=''
source_parity_report=''
quality_baseline=''
report_dir="$cassotis_root/release-validation"
skip_build=0
skip_benchmark=0
skip_desktop=0

usage() {
    cat <<'EOF'
Usage: scripts/validate_release.sh --dictionary DB --dictionary-traditional DB
       --long-cases TSV --short-cases TSV --source-parity-report JSON [OPTIONS]

Options:
  --dictionary-traditional DB  Required traditional release dictionary.
  --report-dir DIR              Validation output directory.
  --quality-baseline FILE       Quality/latency release thresholds.
  --skip-build                  Reuse build/bin.
  --skip-benchmark              Reuse REPORT_DIR/benchmarks/quality-summary.txt.
  --skip-desktop                Skip Fcitx desktop discovery/reload.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dictionary)
            [[ $# -ge 2 ]] || cassotis_die '--dictionary requires a path'
            dictionary_path="$2"; shift ;;
        --dictionary-traditional)
            [[ $# -ge 2 ]] ||
                cassotis_die '--dictionary-traditional requires a path'
            traditional_dictionary_path="$2"; shift ;;
        --long-cases)
            [[ $# -ge 2 ]] || cassotis_die '--long-cases requires a path'
            long_cases="$2"; shift ;;
        --short-cases)
            [[ $# -ge 2 ]] || cassotis_die '--short-cases requires a path'
            short_cases="$2"; shift ;;
        --source-parity-report)
            [[ $# -ge 2 ]] ||
                cassotis_die '--source-parity-report requires a path'
            source_parity_report="$2"; shift ;;
        --report-dir)
            [[ $# -ge 2 ]] || cassotis_die '--report-dir requires a path'
            report_dir="$2"; shift ;;
        --quality-baseline)
            [[ $# -ge 2 ]] || cassotis_die '--quality-baseline requires a path'
            quality_baseline="$2"; shift ;;
        --skip-build) skip_build=1 ;;
        --skip-benchmark) skip_benchmark=1 ;;
        --skip-desktop) skip_desktop=1 ;;
        --help|-h)
            usage
            exit 0 ;;
        *)
            usage >&2
            cassotis_die "unknown release-validation option: $1" ;;
    esac
    shift
done

cassotis_require_linux
cassotis_require_command desktop-file-validate
cassotis_require_command python3
cassotis_require_command realpath
if [[ -z "$quality_baseline" ]]; then
    quality_baseline="$cassotis_root/tests/baselines/quality-v1.17.0-linux-$(uname -m).txt"
fi
for required in dictionary_path traditional_dictionary_path long_cases \
                short_cases source_parity_report quality_baseline; do
    [[ -n "${!required}" && -r "${!required}" ]] ||
        cassotis_die "required input is missing: $required=${!required}"
done
report_dir="$(realpath -m -- "$report_dir")"
[[ "$report_dir" != "$cassotis_root/build"* ]] ||
    cassotis_die 'report directory must be outside build/'
mkdir -p "$report_dir/logs" "$report_dir/benchmarks"

status_file="$report_dir/STATUS"
printf 'running\n' > "$status_file"
on_exit() {
    local status=$?
    if [[ $status -eq 0 ]]; then
        printf 'passed\n' > "$status_file"
    else
        printf 'failed\n' > "$status_file"
    fi
}
trap on_exit EXIT

python3 - "$source_parity_report" "$report_dir/source-parity.json" \
    "$dictionary_path" "$traditional_dictionary_path" <<'PY'
import hashlib
import json
from pathlib import Path
import shutil
import sys

source = Path(sys.argv[1])
destination = Path(sys.argv[2])
dictionary = Path(sys.argv[3])
traditional_dictionary = Path(sys.argv[4])
report = json.loads(source.read_text(encoding="utf-8-sig"))
if report.get("format") != "cassotis-source-parity-v1" or not report.get("ok"):
    raise SystemExit("source parity report is not a successful v1 report")
digest = hashlib.sha256(dictionary.read_bytes()).hexdigest()
if report.get("dictionary", {}).get("sha256") != digest:
    raise SystemExit(
        "source parity report does not describe the selected dictionary"
    )
traditional_digest = hashlib.sha256(traditional_dictionary.read_bytes()).hexdigest()
if report.get("dictionary_traditional", {}).get("sha256") != traditional_digest:
    raise SystemExit(
        "source parity report does not describe the selected traditional dictionary"
    )
shutil.copyfile(source, destination)
PY

if [[ $skip_build -eq 0 ]]; then
    # Release validation must not reuse stale Pascal units from an earlier
    # source snapshot. A clean build is slower but makes the validated source,
    # benchmark binary, adapters, and packaged payload identical.
    "$cassotis_root/scripts/build.sh" --clean \
        >"$report_dir/logs/build.log" 2>&1
fi
"$cassotis_root/scripts/test.sh" --skip-build \
    >"$report_dir/logs/tests.log" 2>&1
"$cassotis_root/scripts/validate_candidates.sh" \
    --dictionary "$dictionary_path" \
    >"$report_dir/logs/candidate-parity.log" 2>&1
"$cassotis_root/scripts/validate_candidates.sh" \
    --dictionary "$traditional_dictionary_path" \
    --cases "$cassotis_root/tests/cases/candidate_quality_tc.tsv" \
    >"$report_dir/logs/candidate-parity-traditional.log" 2>&1
"$cassotis_root/scripts/stress_ibus.sh" \
    --dictionary "$dictionary_path" --skip-build \
    >"$report_dir/logs/transport-stress.log" 2>&1

benchmark_inputs="$report_dir/benchmarks/benchmark-inputs.json"
python3 - "$dictionary_path" "$long_cases" "$short_cases" \
    "$cassotis_root/build/bin/cassotis-quality-benchmark" \
    "$cassotis_root/VERSION" "$benchmark_inputs" "$skip_benchmark" <<'PY'
import hashlib
import json
from pathlib import Path
import sys


def file_record(path_text: str) -> dict[str, object]:
    path = Path(path_text)
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return {
        "file": path.name,
        "bytes": path.stat().st_size,
        "sha256": digest.hexdigest(),
    }


destination = Path(sys.argv[6])
reuse = sys.argv[7] == "1"
current = {
    "format": "cassotis-quality-inputs-v1",
    "release_version": Path(sys.argv[5]).read_text(encoding="utf-8").strip(),
    "dictionary": file_record(sys.argv[1]),
    "long_cases": file_record(sys.argv[2]),
    "short_cases": file_record(sys.argv[3]),
    "benchmark_binary": file_record(sys.argv[4]),
}
if reuse:
    if not destination.is_file():
        raise SystemExit("benchmark input manifest is missing")
    previous = json.loads(destination.read_text(encoding="utf-8"))
    if previous != current:
        raise SystemExit("saved benchmark inputs do not match this release")
else:
    destination.write_text(
        json.dumps(current, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
PY

if [[ $skip_benchmark -eq 0 ]]; then
    "$cassotis_root/build/bin/cassotis-quality-benchmark" \
        --dictionary "$dictionary_path" \
        --long-cases "$long_cases" --short-cases "$short_cases" \
        --report-dir "$report_dir/benchmarks" --progress-every 1000 \
        >"$report_dir/logs/quality-benchmark.log" 2>&1
fi
python3 "$cassotis_root/tools/parity/validate_quality_report.py" \
    --summary "$report_dir/benchmarks/quality-summary.txt" \
    --dictionary "$dictionary_path" \
    --long-cases "$long_cases" --short-cases "$short_cases" \
    --baseline "$quality_baseline" \
    --report "$report_dir/quality-validation.json" \
    >"$report_dir/logs/quality-validation.log"

release_args=(--dictionary "$dictionary_path" \
    --output "$report_dir/artifacts" --skip-build)
matrix_args=(--dictionary "$dictionary_path" \
    --report-dir "$report_dir/platform-matrix" --skip-build)
if [[ -n "$traditional_dictionary_path" ]]; then
    release_args+=(--dictionary-traditional "$traditional_dictionary_path")
    matrix_args+=(--dictionary-traditional "$traditional_dictionary_path")
fi
if [[ $skip_desktop -eq 1 ]]; then
    matrix_args+=(--skip-desktop)
fi
"$cassotis_root/scripts/build_release.sh" "${release_args[@]}" \
    >"$report_dir/logs/build-release.log" 2>&1
"$cassotis_root/scripts/validate_release_artifacts.sh" \
    --artifacts "$report_dir/artifacts" \
    --dictionary "$dictionary_path" \
    --dictionary-traditional "$traditional_dictionary_path" \
    >"$report_dir/logs/release-artifacts.log" 2>&1
"$cassotis_root/scripts/validate_platform_matrix.sh" "${matrix_args[@]}" \
    >"$report_dir/logs/platform-matrix.log" 2>&1

python3 - "$report_dir" "$cassotis_root/VERSION" <<'PY'
import json
from pathlib import Path
import platform
import sys
from datetime import datetime, timezone

root = Path(sys.argv[1])
version = Path(sys.argv[2]).read_text(encoding="utf-8").strip()
quality = json.loads((root / "quality-validation.json").read_text(encoding="utf-8"))
source = json.loads((root / "source-parity.json").read_text(encoding="utf-8"))
quality_inputs = json.loads(
    (root / "benchmarks" / "benchmark-inputs.json").read_text(encoding="utf-8")
)
artifact_checksums = {}
for line in (root / "artifacts" / "SHA256SUMS").read_text(
    encoding="utf-8"
).splitlines():
    digest, name = line.split(maxsplit=1)
    artifact_checksums[name.lstrip("*")] = digest
matrix = []
for index, line in enumerate(
    (root / "platform-matrix" / "platform-matrix.tsv").read_text(
        encoding="utf-8"
    ).splitlines()
):
    if index == 0 or not line:
        continue
    framework, stage, result, log = line.split("\t")
    matrix.append(
        {"framework": framework, "stage": stage, "result": result, "log": log}
    )
summary = {
    "format": "cassotis-release-validation-v1",
    "version": version,
    "generated_at": datetime.now(timezone.utc).isoformat(),
    "platform": platform.platform(),
    "source_parity": {
        "ok": source["ok"],
        "windows_head": source["windows_head"],
        "lexicon_head": source["lexicon_head"],
        "dictionary": source["dictionary"],
        "dictionary_traditional": source["dictionary_traditional"],
    },
    "quality": quality["metrics"],
    "quality_inputs": quality_inputs,
    "artifact_sha256": artifact_checksums,
    "platform_matrix_results": matrix,
    "core_tests": "passed",
    "candidate_parity_simplified": "passed",
    "candidate_parity_traditional": "passed",
    "transport_stress": "passed",
    "release_artifacts": "passed",
    "platform_matrix": "passed",
    "ok": True,
}
(root / "release-validation.json").write_text(
    json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
)
PY

printf 'release_validation.report=%s\n' "$report_dir/release-validation.json"
printf 'release_validation.status=passed\n'
