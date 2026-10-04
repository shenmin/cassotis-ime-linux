#!/usr/bin/env python3
"""Reconstruct the character model from contiguous, hash-verified Git parts."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import tempfile


def assemble(directory: Path, destination: Path) -> Path:
    manifest = json.loads((directory / "runtime_manifest.json").read_text(encoding="utf-8-sig"))
    expected = manifest.get("files", {}).get("char_lm.onnx", "")
    if manifest.get("format") != 1 or not re.fullmatch(r"[0-9a-f]{64}", expected):
        raise ValueError("invalid character model manifest")
    parts = sorted(directory.glob("char_lm.onnx.*"))
    if not parts or len(parts) > 1000:
        raise ValueError("missing character model parts")
    for index, part in enumerate(parts):
        if part.name != f"char_lm.onnx.{index:03d}" or not part.is_file() or part.stat().st_size == 0:
            raise ValueError("character model parts must be nonempty and contiguous from 000")
    destination.parent.mkdir(parents=True, exist_ok=True)
    fd, temporary = tempfile.mkstemp(prefix=".char-lm-", dir=destination.parent)
    try:
        digest = hashlib.sha256()
        with os.fdopen(fd, "wb") as output:
            for part in parts:
                with part.open("rb") as source:
                    for chunk in iter(lambda: source.read(1024 * 1024), b""):
                        digest.update(chunk)
                        output.write(chunk)
            output.flush()
            os.fsync(output.fileno())
        if digest.hexdigest() != expected:
            raise ValueError("character model SHA-256 mismatch")
        os.replace(temporary, destination)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)
    return destination


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("directory", type=Path)
    parser.add_argument("destination", type=Path)
    args = parser.parse_args()
    assemble(args.directory, args.destination)
    print("character_model.parts=verified")


if __name__ == "__main__":
    main()
