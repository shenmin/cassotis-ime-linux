#!/usr/bin/env python3
"""Exercise production IPC before, during and after delayed neural loading."""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import time


def wait_for(path: Path, process: subprocess.Popen, timeout: float) -> None:
    deadline = time.monotonic() + timeout
    while not path.exists():
        if process.poll() is not None:
            raise RuntimeError(f"engine exited with {process.returncode}")
        if time.monotonic() >= deadline:
            raise TimeoutError(f"engine did not reach {path.name} within {timeout}s")
        time.sleep(0.005)


def metrics(output: str) -> dict:
    values = dict(line.split("=", 1) for line in output.splitlines() if "=" in line)
    if values.get("cold_start_input") != "passed":
        raise AssertionError(output)
    return {
        "first_key_ms": float(values["first_key_ms"]),
        "maximum_key_ms": float(values["maximum_key_ms"]),
        "key_count": int(values["key_count"]),
    }


def exercise(runtime: Path, socket: Path, engine: Path, log: Path) -> dict:
    command = [str(runtime / "cassotis-cold-start-smoke"), str(socket), str(engine)]
    try:
        client = subprocess.run(command, capture_output=True, text=True, timeout=15)
    except subprocess.TimeoutExpired as error:
        output = error.stdout or b""
        errors = error.stderr or b""
        if isinstance(output, bytes):
            output = output.decode("utf-8", errors="replace")
        if isinstance(errors, bytes):
            errors = errors.decode("utf-8", errors="replace")
        log.write_text(output, encoding="utf-8")
        log.with_suffix(".stderr").write_text(errors, encoding="utf-8")
        raise
    log.write_text(client.stdout, encoding="utf-8")
    log.with_suffix(".stderr").write_text(client.stderr, encoding="utf-8")
    client.check_returncode()
    return metrics(client.stdout)


def trial(runtime: Path, dictionary: Path, report: Path, blocked: bool) -> dict:
    report.mkdir()
    # A short, private socket path also avoids touching a desktop engine.
    with tempfile.TemporaryDirectory(prefix="cassotis-cold-") as directory:
        root = Path(directory)
        engine = root / "cassotis-engine"
        shutil.copy2(runtime / engine.name, engine)
        for name in ("pinyin_transformer", "local_completion", "local_repair"):
            (root / name).symlink_to(runtime / name, target_is_directory=True)
        for library in runtime.glob("*.so*"):
            (root / library.name).symlink_to(library)
        socket = root / "engine.sock"
        environment = os.environ.copy()
        for name in tuple(environment):
            if name.startswith("CASSOTIS_") or name == "LD_PRELOAD":
                environment.pop(name)
        environment["LD_LIBRARY_PATH"] = str(root)
        environment["CASSOTIS_PINYIN_TRANSFORMER_PROFILE"] = "1"
        environment["CASSOTIS_LOCAL_COMPLETION_PROFILE"] = "1"
        if blocked:
            environment["LD_PRELOAD"] = str(runtime / "model-load-barrier.so")
            environment["CASSOTIS_TEST_MODEL_BARRIER"] = str(root)
        with (report / "engine.log").open("wb") as log:
            started = time.monotonic()
            process = subprocess.Popen(
                [str(engine), "--serve", "--socket", str(socket),
                 "--dictionary", str(dictionary),
                 "--dictionary-traditional", str(dictionary),
                 "--user-dictionary", str(root / "user.db")],
                env=environment, stdout=log, stderr=subprocess.STDOUT,
            )
            try:
                wait_for(socket, process, 5.0)
                socket_ms = (time.monotonic() - started) * 1000
                if blocked:
                    wait_for(root / "entered", process, 5.0)
                result = exercise(runtime, socket, engine, report / "input.log")
                result["socket_ms"] = round(socket_ms, 3)
                result["model_initialization_blocked"] = blocked
                if blocked:
                    # Inputs must finish while initialization is STILL blocked.
                    if not (root / "entered").exists() or (root / "release").exists():
                        raise AssertionError("model barrier was not held for input")
                (root / "release").touch()
                # Let real initialization and warm-up complete before shutdown.
                deadline = time.monotonic() + 30
                while time.monotonic() < deadline:
                    text = (report / "engine.log").read_text(
                        encoding="utf-8", errors="replace")
                    if "INT8 model loaded and warmed" in text and \
                            "local-repair INT8 graphs loaded" in text and \
                            "local-completion INT8 models loaded" in text:
                        break
                    if process.poll() is not None:
                        raise RuntimeError("engine exited during background loading")
                    time.sleep(0.05)
                else:
                    raise TimeoutError("real model initialization did not recover")
                result["ready_input"] = exercise(
                    runtime, socket, engine, report / "ready-input.log")
                return result
            finally:
                (root / "release").touch()
                if process.poll() is None:
                    control_environment = environment.copy()
                    control_environment.pop("LD_PRELOAD", None)
                    control_environment["CASSOTIS_ENGINE_SOCKET"] = str(socket)
                    control_environment["CASSOTIS_ENGINE_PATH"] = str(engine)
                    try:
                        subprocess.run([str(runtime / "cassotis-control"), "shutdown"],
                                       env=control_environment, capture_output=True,
                                       timeout=5, check=True)
                        process.wait(timeout=30)
                    except (subprocess.SubprocessError, OSError):
                        process.kill()
                        process.wait(timeout=5)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--runtime", type=Path, required=True)
    parser.add_argument("--dictionary", type=Path, required=True)
    parser.add_argument("--report-dir", type=Path, required=True)
    args = parser.parse_args()
    runtime = args.runtime.resolve(strict=True)
    dictionary = args.dictionary.resolve(strict=True)
    args.report_dir.mkdir(parents=True, exist_ok=False)
    results = {
        "blocked": trial(runtime, dictionary, args.report_dir / "blocked", True),
        "process_cold": trial(runtime, dictionary, args.report_dir / "process-cold", False),
        "scope": "new production processes; system file caches are not dropped",
        "ok": True,
    }
    content = json.dumps(results, indent=2) + "\n"
    (args.report_dir / "summary.json").write_text(content, encoding="utf-8")
    print(content, end="")


if __name__ == "__main__":
    main()
