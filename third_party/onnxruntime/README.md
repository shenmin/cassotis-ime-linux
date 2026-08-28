# ONNX Runtime

Cassotis IME uses the official CPU builds of ONNX Runtime 1.20.1 for Linux.
The repository carries the runtime libraries for `x86_64` and `aarch64`; the
build selects exactly one architecture and packages only that runtime.

Upstream project: https://github.com/microsoft/onnxruntime

Archive checksums:

| Archive | SHA-256 |
| --- | --- |
| `onnxruntime-linux-x64-1.20.1.tgz` | `67db4dc1561f1e3fd42e619575c82c601ef89849afc7ea85a003abbac1a1a105` |
| `onnxruntime-linux-aarch64-1.20.1.tgz` | `ae4fedbdc8c18d688c01306b4b50c63de3445cdf2dbd720e01a2fa3810b8106a` |

See `LICENSE` and `ThirdPartyNotices.txt` in this directory for redistribution
terms and notices.
