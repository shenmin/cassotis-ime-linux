# Compatibility

## Binary Release Matrix

| Platform | IBus | Fcitx 5 | Status |
| --- | --- | --- | --- |
| Ubuntu 26.04 x86_64, GNOME, Wayland | Native adapter, real daemon input-context smoke | Native addon, official testfrontend plus desktop discovery/reload | Release gate |
| Ubuntu 26.04 x86_64, GNOME, X11 | Expected from the same framework APIs | Expected from the same framework APIs | Not yet release-gated |
| Linux aarch64 | Source target available | Source target available | Build target; binary release pending hardware validation |
| Other distributions | Source build | Source build | Community-tested; no repackaged Debian binaries |

The release-gated host uses Linux 7.0.0, Free Pascal 3.2.2, IBus
1.5.34-rc2, and Fcitx 5.1.19. The automated matrix was last completed on
2026-08-25. Package/portable validation uses the same native binaries and
schema-22 simplified/traditional dictionaries.

Both framework adapters are deliberately thin. Parsing, dictionaries,
ranking, completion, settings state, and user learning live in the same local
engine, so framework choice must not change candidate quality.

## Automated Framework Matrix

Run:

```bash
./scripts/validate_platform_matrix.sh \
  --dictionary /path/to/dict_sc.db \
  --dictionary-traditional /path/to/dict_tc.db \
  --report-dir ./platform-matrix
```

The matrix performs:

| Framework | Automated assertion |
| --- | --- |
| IBus | Per-user installation, settings state round-trip, real desktop-daemon input context, preedit, candidates, raw commit, debug-weight mode, engine restart recovery |
| Fcitx 5 | Per-user installation, official isolated native testfrontend key path, candidate and completion behavior, settings state, addon discovery and reload in the real desktop daemon |
| Shared engine | One socket service, shared simplified/traditional dictionaries, shared user learning, all seven pinyin modes |

On GNOME the scripts snapshot and restore the exact input-source list, MRU
order, current index, and prior framework state. Failure to restore that state
is itself a test failure.

The generated `platform-matrix.tsv` and `platform-matrix.md` are release
records. A successful matrix must contain five passed stages: both per-user
installs, IBus real-daemon input, Fcitx isolated native input, and Fcitx real-
daemon discovery/reload.

## Manual Release Checks

Wayland prevents an SSH-launched process from reliably stealing focus. The
following remain explicit manual checks before publishing a release:

- Enable Cassotis from GNOME Settings and type in one GTK 3 and one GTK 4 app.
- Switch between IBus and Fcitx 5 and confirm the same candidate order.
- Exercise simplified/traditional, full pinyin, one shuangpin scheme, user
  learning/deletion, completion, and the settings launcher.
- Confirm candidate placement and scaling on the release desktop.

Floating status-window styling, a tray application, and product logging are
not part of the Linux v0.1.0 release scope.
