#!/usr/bin/env python3
"""Losslessly store large ONNX FLOAT initializers as file-backed external data.

ORT maps external CPU tensors instead of copying entire embedding tables onto
the heap. Graph operations, tensor shapes, precision and raw bytes do not change.
Canonical models remain unchanged; only build/runtime copies are repackaged.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import math
import os
from pathlib import Path
import re
import tempfile

MODELS = (
    "pinyin_transformer/pinyin_conditional_scorer_int8.onnx",
    "pinyin_transformer/pinyin_parallel_generator_int8.onnx",
    "local_completion/local_completion_path_ranker_int8.onnx",
    "local_completion/local_completion_generator_int8.onnx",
    "local_repair/context_int8.onnx",
    "local_repair/query_int8.onnx",
    "local_repair/joint_query_int8.onnx",
    "short_context/exit0.int8.onnx",
    "short_context/exit1.int8.onnx",
    "short_context/exit2.int8.onnx",
    "short_context/exit3.int8.onnx",
)
# The small repair heads are loaded from in-memory compatibility graphs, so
# external paths cannot be resolved for those models. Keep their storage inline.
MIN_BYTES = 1024 * 1024
ALIGNMENT = 65536


def varint(data: bytes, pos: int) -> tuple[int, int]:
    value = 0
    for shift in range(0, 70, 7):
        if pos >= len(data):
            raise ValueError("truncated protobuf varint")
        part = data[pos]
        pos += 1
        if shift == 63 and part > 1:
            raise ValueError("protobuf varint overflow")
        value |= (part & 127) << shift
        if part < 128:
            return value, pos
    raise ValueError("invalid protobuf varint")


def encode(value: int) -> bytes:
    result = bytearray()
    while value > 127:
        result.append((value & 127) | 128)
        value >>= 7
    result.append(value)
    return bytes(result)


def message(number: int, data: bytes) -> bytes:
    return encode(number * 8 + 2) + encode(len(data)) + data


def fields(data: bytes):
    pos = 0
    while pos < len(data):
        begin = pos
        tag, pos = varint(data, pos)
        number, wire = tag >> 3, tag & 7
        if not number:
            raise ValueError("invalid protobuf field number")
        if wire == 0:
            value, pos = varint(data, pos)
        elif wire in (1, 2, 5):
            if wire == 2:
                size, pos = varint(data, pos)
            else:
                size = 8 if wire == 1 else 4
            value = data[pos:pos + size]
            pos += size
        else:
            raise ValueError("unsupported protobuf wire type")
        if pos > len(data):
            raise ValueError("truncated protobuf field")
        yield number, wire, value, data[begin:pos]


def replace_tensors(model: bytes, transform) -> bytes:
    result = []
    for number, wire, value, raw in fields(model):
        if number == 7 and wire == 2:
            graph = b"".join(message(n, transform(v)) if n == 5 and w == 2 else b
                             for n, w, v, b in fields(value))
            result.append(message(number, graph))
        else:
            result.append(raw)
    return b"".join(result)


def external_info(tensor: bytes) -> dict[str, str]:
    info = {}
    for number, wire, value, _ in fields(tensor):
        if number == 13 and wire == 2:
            entry = {n: v for n, w, v, _ in fields(value) if w == 2}
            key, val = entry[1].decode("utf-8"), entry[2].decode("utf-8")
            if key in info:
                raise ValueError("duplicate external tensor metadata")
            info[key] = val
    return info


def owned_weight(model: Path, name: str) -> bool:
    return re.fullmatch(re.escape(model.name) + r"\.[0-9a-f]{64}\.weights", name) is not None


def atomic_write(path: Path, data: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temporary = tempfile.mkstemp(prefix=".cassotis-weights-", dir=path.parent)
    try:
        with os.fdopen(fd, "wb") as stream:
            stream.write(data)
            stream.flush()
            os.fsync(stream.fileno())
        os.chmod(temporary, 0o644)
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def pack_model(source: Path, destination: Path) -> int:
    original = source.read_bytes()
    weights = bytearray()
    count = 0
    original_tensors = []
    # Content-addressed filenames keep an old model and its weight file paired
    # even if another process opens a model during an atomic runtime upgrade.
    name = destination.name + "." + hashlib.sha256(original).hexdigest() + ".weights"

    def pack(tensor):
        nonlocal count
        parts = list(fields(tensor))
        original_tensors.append(parts)
        if any(n == 13 or (n == 14 and (w != 0 or v != 0)) for n, w, v, _ in parts):
            raise ValueError("expected a canonical model with inline tensors")
        dtype = next((v for n, w, v, _ in parts if n == 2 and w == 0), 0)
        raws = [v for n, w, v, _ in parts if n == 9 and w == 2]
        if len(raws) > 1:
            raise ValueError("duplicate raw tensor data")
        if dtype != 1 or not raws or len(raws[0]) < MIN_BYTES:
            return tensor
        dims = []
        for n, w, v, _ in parts:
            if n == 1:
                if w == 0:
                    dims.append(v)
                elif w == 2:
                    pos = 0
                    while pos < len(v):
                        dim, pos = varint(v, pos)
                        dims.append(dim)
        raw = raws[0]
        if math.prod(dims) * 4 != len(raw) or any(d >= 2**63 for d in dims):
            raise ValueError("FLOAT initializer shape/byte size mismatch")
        offset = (len(weights) + ALIGNMENT - 1) // ALIGNMENT * ALIGNMENT
        weights.extend(b"\0" * (offset - len(weights)))
        weights.extend(raw)
        entries = (("location", name), ("offset", str(offset)), ("length", str(len(raw))))
        external = b"".join(message(13, message(1, k.encode()) + message(2, v.encode()))
                            for k, v in entries) + encode(14 * 8) + encode(1)
        count += 1
        return b"".join(external if n == 9 else b for n, w, v, b in parts if n != 14)

    packed = replace_tensors(original, pack)
    # Reconstruct the complete original protobuf, not just tensor sums or model
    # accuracy. This also checks graph metadata and the ordering of all fields.
    originals = iter(original_tensors)
    def restore(tensor):
        original_parts = next(originals)
        info = external_info(tensor)
        if not info:
            return tensor
        start, size = int(info["offset"]), int(info["length"])
        if info["location"] != name or start < 0 or size < 0 or start + size > len(weights):
            raise ValueError("invalid generated external tensor range")
        metadata = b"".join(b for n, w, v, b in fields(tensor) if n not in (9, 13, 14))
        original_metadata = b"".join(b for n, w, v, b in original_parts if n not in (9, 13, 14))
        if metadata != original_metadata:
            raise ValueError("tensor metadata changed during conversion")
        # Some exporters explicitly serialize DEFAULT=0 (field 14). Restore
        # its original position as well as the raw data field for exact hashing.
        return b"".join(message(9, bytes(weights[start:start + size])) if n == 9 else b
                        for n, w, v, b in original_parts)
    if replace_tensors(packed, restore) != original:
        raise ValueError("model did not survive byte-for-byte round trip")
    if count:
        atomic_write(destination.with_name(name), weights)
    atomic_write(destination, packed)
    return count


def referenced_weights(model: Path) -> set[Path]:
    result = set()
    def inspect(tensor):
        info = external_info(tensor)
        if info:
            name = info["location"]
            if not owned_weight(model, name):
                raise ValueError("unexpected external weight filename")
            path = model.with_name(name)
            start, size = int(info["offset"]), int(info["length"])
            if start < 0 or size < 0 or start + size > path.stat().st_size:
                raise ValueError("external weight range exceeds file")
            result.add(path)
        return tensor
    replace_tensors(model.read_bytes(), inspect)
    return result


def copy_weights(source: Path, destination: Path) -> None:
    for relative in MODELS:
        model = source / relative
        # Also support runtime directories made by earlier builds, which have
        # no sidecars (including staging fixtures with placeholder model files).
        if not model.is_file():
            continue
        if not any(model.parent.glob(model.name + ".*.weights")) and b".weights" not in model.read_bytes():
            continue
        for path in referenced_weights(model):
            atomic_write(destination / path.relative_to(source), path.read_bytes())


def update_short_manifest(source: Path, destination: Path) -> None:
    folder = destination / "short_context"
    manifest = json.loads((source / "short_context/runtime_manifest.json").read_text(encoding="utf-8"))
    files = manifest["files"]
    expected = {f"exit{i}.int8.onnx" for i in range(4)} | {"tokenizer.bin", "policy.bin"}
    if set(files) != expected:
        raise ValueError("unexpected canonical short-context manifest")
    manifest["canonical_files"] = dict(files)
    external = {}
    for name in sorted(expected):
        original = source / "short_context" / name
        if hashlib.sha256(original.read_bytes()).hexdigest() != files[name]:
            raise ValueError("canonical short-context asset hash mismatch: " + name)
        path = folder / name
        files[name] = hashlib.sha256(path.read_bytes()).hexdigest()
        if name.endswith(".onnx"):
            for weight in referenced_weights(path):
                external[weight.name] = hashlib.sha256(weight.read_bytes()).hexdigest()
    manifest["storage"] = "onnx-external-v1"
    manifest["external_files"] = external
    atomic_write(folder / "runtime_manifest.json",
                 (json.dumps(manifest, ensure_ascii=True, indent=2) + "\n").encode("utf-8"))


def remove_weights(root: Path) -> None:
    for relative in MODELS:
        model = root / relative
        for path in model.parent.glob(model.name + ".*.weights"):
            if owned_weight(model, path.name) and (path.is_file() or path.is_symlink()):
                path.unlink()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    modes = parser.add_mutually_exclusive_group(required=True)
    modes.add_argument("--pack", action="store_true")
    modes.add_argument("--copy-weights", action="store_true")
    modes.add_argument("--remove-weights", action="store_true")
    parser.add_argument("source", type=Path)
    parser.add_argument("destination", type=Path, nargs="?")
    args = parser.parse_args()
    if args.remove_weights:
        remove_weights(args.source)
    else:
        if args.destination is None:
            parser.error("destination is required")
        if args.pack:
            if args.source.resolve() == args.destination.resolve():
                parser.error("canonical source and runtime destination must differ")
            for relative in MODELS:
                count = pack_model(args.source / relative, args.destination / relative)
                print(f"[weights] {relative}: {count} external tensors; exact round trip")
            update_short_manifest(args.source, args.destination)
        else:
            copy_weights(args.source, args.destination)


if __name__ == "__main__":
    main()
