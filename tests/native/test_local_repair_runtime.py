#!/usr/bin/env python3
"""Exercise the shipped repair ABI, not a separate inference implementation."""

from __future__ import annotations

import ctypes as c
import json
import math
from pathlib import Path
import sys


def main() -> None:
    root = Path(sys.argv[1]).resolve()
    model = root / "local_repair"
    vocab = json.loads((model / "vocab.json").read_text(encoding="utf-8"))
    readings = json.loads((model / "readings.json").read_text(encoding="utf-8"))
    library = c.CDLL(str(root / "libcassotis_pinyin_transformer_ort.so"))
    create = library.cassotis_lr_create
    create.argtypes = [c.c_char_p, c.c_char_p, c.c_int, c.c_char_p, c.c_int]
    create.restype = c.c_void_p
    run = library.cassotis_lr_run
    run.argtypes = [c.c_void_p, c.c_uint64, c.POINTER(c.c_int64), c.c_int,
                   c.POINTER(c.c_int64), c.POINTER(c.c_int64), c.c_int,
                   c.POINTER(c.c_int64), c.POINTER(c.c_float),
                   c.POINTER(c.c_float), c.c_char_p, c.c_int]
    run.restype = c.c_int
    prepare = library.cassotis_lr_prepare_context
    prepare.argtypes = [c.c_void_p, c.c_uint64, c.POINTER(c.c_int64),
                       c.c_int, c.c_char_p, c.c_int]
    prepare.restype = c.c_int
    encodings = library.cassotis_lr_encodings
    encodings.argtypes = [c.c_void_p]
    encodings.restype = c.c_uint64
    clear = library.cassotis_lr_clear
    destroy = library.cassotis_lr_destroy
    for function in (clear, destroy):
        function.argtypes = [c.c_void_p]
        function.restype = None

    error = c.create_string_buffer(2048)
    handle = create(str(model / "context_int8.onnx").encode(),
                    str(model / "query_int8.onnx").encode(), 2, error, len(error))
    assert handle, error.value
    try:
        # An invented phrase keeps the contract independent of benchmark cases.
        text = "\u4eca\u5929\u6211\u4eec\u4e00\u8d77\u5403\u996d"
        syllables = "jin tian wo men yi qi chi fan".split()
        length = len(text)
        draft = (c.c_int64 * length)(*(vocab["char"][ch] for ch in text))
        pinyin = (c.c_int64 * length)(*(vocab["pinyin"][py] for py in syllables))

        def infer(document: int, context: list[int]):
            ids = (c.c_int64 * len(context))(*context)
            best = (c.c_int64 * length)()
            margins, edits = (c.c_float * length)(), (c.c_float * length)()
            assert run(handle, document, ids, len(ids), draft, pinyin, length,
                       best, margins, edits, error, len(error)) == 1, error.value
            for index, py in enumerate(pinyin):
                assert best[index] in readings[str(py)], "reading constraint lost"
                assert math.isfinite(margins[index])
                assert math.isfinite(edits[index]) and 0 <= edits[index] <= 1
            return tuple(best), tuple(margins), tuple(edits)

        empty = [3, 2]
        first = infer(1, empty)
        assert encodings(handle) == 1
        assert infer(1, empty) == first
        assert encodings(handle) == 1, "unchanged context was encoded again"
        ids = (c.c_int64 * 2)(*empty)
        assert prepare(handle, 1, ids, 2, error, len(error)) == 1
        assert encodings(handle) == 1
        assert infer(2, empty) == first
        assert encodings(handle) == 2, "document identity was ignored"
        full = [3] + [vocab["char"][text[0]]] * 256 + [2]
        infer(2, full)
        assert encodings(handle) == 3, "changed text reused stale memory"
        clear(handle)
        assert infer(2, empty) == first, "clear did not restore empty-context output"
        assert encodings(handle) == 4
        assert prepare(handle, 2, ids, 1, error, len(error)) == 0
        assert encodings(handle) == 4, "invalid input changed the cache"
    finally:
        destroy(handle)
    print("local_repair_runtime=passed")


if __name__ == "__main__":
    main()
