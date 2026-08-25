# Cassotis Engine IPC

This document defines protocol version 1.0 between `cassotis-engine`, the IBus
adapter, the Fcitx 5 adapter, and `cassotis-control`. Candidate and ranking
policy never crosses into an adapter.

## Transport

The engine listens on an owner-only Unix-domain socket at
`$XDG_RUNTIME_DIR/cassotis-ime/engine.sock`. Its directory is mode `0700` and
the socket is mode `0600`. The server holds an advisory lock on
`engine.sock.lock` while probing, removing a stale path, binding, and serving;
this prevents two adapters racing at cold start from creating split engine
instances.

The service accepts at most 16 clients. A single-threaded event loop buffers
partial frames per connection and dispatches complete requests serially, so a
slow peer cannot corrupt another connection's stream or concurrently enter the
Pascal engine/SQLite state. Context and buffered-byte counts are bounded.

All integers are little-endian, text is strictly validated UTF-8, and one
frame payload is limited to 8 MiB.

## Frame Header

Every frame starts with this fixed 44-byte header:

| Offset | Size | Field | Description |
| ---: | ---: | --- | --- |
| 0 | 4 | magic | ASCII `CSIM` |
| 4 | 2 | protocol major | Incompatible generation; currently `1` |
| 6 | 2 | protocol minor | Compatible revision; currently `0` |
| 8 | 2 | message type | Stable `TncIpcMessageType` ordinal |
| 10 | 2 | reserved | Zero |
| 12 | 4 | flags | Bit 0 response, bit 1 error |
| 16 | 8 | request id | Correlates one request/response |
| 24 | 8 | context id | Connection-local framework context |
| 32 | 8 | generation id | Rejects stale context operations |
| 40 | 4 | payload length | Bytes after the header |

The decoder consumes exactly one frame and leaves later frames buffered. An
incomplete frame is not an error; invalid magic/version/type/flags/length is.

## Message Types

Message ordinals are wire ABI and must not be reordered.

| Ordinal | Name | Direction/status |
| ---: | --- | --- |
| 1 | `hello` | Reserved for capability negotiation |
| 2 | `hello_ack` | Reserved response |
| 3 | `ping` | Request; opaque payload is echoed |
| 4 | `pong` | Response |
| 5 | `create_context` | Request |
| 6 | `destroy_context` | Request |
| 7 | `reset_context` | Request |
| 8 | `set_active` | Request |
| 9 | `set_surrounding` | Request |
| 10 | `process_key` | Request |
| 11 | `engine_result` | Response |
| 12 | `get_state` | Request/state response |
| 13 | `set_state` | Request/empty response |
| 14 | `shutdown` | Request/acknowledgement |
| 15 | `error` | Structured response |

`create_context`, `destroy_context`, and `reset_context` have empty payloads.
Structured payloads start with `u16 schema_version` and `u16 reserved`.

## Payload Primitives

| Type | Encoding |
| --- | --- |
| boolean | One byte, exactly `0` or `1` |
| `u16`, `u32`, `u64`, `i32` | Little-endian fixed-width integer |
| string | `u32` byte count followed by strict UTF-8 |

One string is limited to 1 MiB. Decoders reject truncation, trailing data,
unknown enum/flag values, non-zero reserved fields, and invalid UTF-8.

## Input Requests

`set_active` contains one boolean. `set_surrounding` contains a non-negative
`i32` cursor offset and one string. The cursor is measured in UTF-16 code
units, matching the engine's `UnicodeString`; adapters convert their native
cursor convention at this boundary.

`process_key` contains:

| Order | Type | Field |
| ---: | --- | --- |
| 1 | `u16` | framework-neutral special-key ordinal |
| 2 | `u16` | reserved |
| 3 | `u32` | Shift/Ctrl/Alt/Super/Caps/Num modifier mask |
| 4 | `u32` | framework scan code |
| 5 | `u32` | bit 0 release, bit 1 repeat |
| 6 | `u64` | monotonic timestamp in milliseconds |
| 7 | string | framework-decoded text |

## Engine Result

The schema-v1 result contains handled/selection/page/error fields followed by
commit text, preedit text, normalized query, one-key completion, error text,
and at most 256 candidates. Each candidate contains source, display kind,
dictionary-weight/deletable flags, final score, dictionary weight, fuzzy cost
and rule mask, text, and annotation.

Adapters render only this result. A candidate is shown as deletable only when
the engine marks a persistent user candidate deletable.

## Engine State Schema 4

The current state payload is schema 4:

| Order | Type | Field |
| ---: | --- | --- |
| 1 | `u8` | input mode |
| 2 | `u8` | simplified/traditional dictionary |
| 3 | `u8` | pinyin scheme |
| 4 | `u8` | full-width, Chinese-punctuation, fuzzy, debug flags |
| 5 | `u32` | fuzzy-rule mask |
| 6 | `u8` | candidate paging-key scheme |
| 7 | `u8` | one-key-completion key |
| 8 | `u8` | page size, 3 through 9 |
| 9 | `u8` | reserved |
| 10 | 5 x shortcut | mode, punctuation, dictionary, width, settings |

One shortcut is `u16 key_code`, `u8` Shift/Ctrl/Alt mask, and one reserved
byte. Duplicate or unsafe shortcuts and a Tab paging/completion conflict are
rejected.

State decoders remain backward-compatible: schema 1 carries the first four
bytes, schema 2 adds fuzzy rules, and schema 3 adds paging/completion and five
shortcuts with a reserved `u16`. Schema 4 adds page size and debug mode. Other
payload types remain schema 1.

Pinyin ordinals are full pinyin, Microsoft, Xiaohe, Ziranma, Sogou, Ziguang,
and Pinyin Jiajia. Persisted settings are engine-owned and shared by both
frameworks. Changes that alter input interpretation clear active compositions.

## Errors And Lifecycle

An error payload is `u32 error_code` plus one UTF-8 message. Current codes are
1001 invalid request, 1002 invalid payload, 1003 context/lifecycle failure,
and 1004 unimplemented request.

Wire context ids are connection-local. The service maps them to unique engine
contexts and destroys only that client's mappings on disconnect. Generation
ids never decrease within a context; stale requests and responses are
discarded. Adapters use bounded transport timeouts, reconnect after an engine
restart, recreate their context, and synchronize active/surrounding state.

Protocol major changes are rejected. A newer minor is rejected until explicit
negotiation is implemented. Pascal records are never copied to the wire, and
existing fields or enum ordinals must not be repurposed.
