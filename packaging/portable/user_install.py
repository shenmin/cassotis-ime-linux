#!/usr/bin/env python3

"""Relocate a verified binary bundle into the desktop user's XDG directories."""

from __future__ import annotations

import argparse
import ast
import fcntl
import hashlib
import json
import os
import platform
import re
import shlex
import shutil
import stat
import subprocess
import sys
import tempfile
import time
import xml.etree.ElementTree as ET
from dataclasses import dataclass
from pathlib import Path, PurePosixPath


FORMAT = "cassotis-user-install-v1"
LIBEXEC = "usr/libexec/cassotis-ime/"
DATA = "usr/share/cassotis-ime/"
DOCS = "usr/share/doc/cassotis-ime/"
IBUS_SERVICE = "org.freedesktop.IBus.session.GNOME.service"


class InstallError(Exception):
    pass


def digest(path: Path) -> str:
    result = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            result.update(block)
    return result.hexdigest()


def relative_path(value: str) -> str:
    path = PurePosixPath(value)
    if (not value or path.is_absolute() or ".." in path.parts or
            str(path) != value or any(ord(c) < 32 for c in value)):
        raise InstallError(f"Unsafe relative path: {value!r}")
    return value


def command(args: list[str], *, env=None, timeout=5, required=False):
    try:
        result = subprocess.run(args, env=env, timeout=timeout, text=True,
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except (OSError, subprocess.TimeoutExpired) as exc:
        if required:
            raise InstallError(f"Cannot run {args[0]}: {exc}") from exc
        return None
    if required and result.returncode:
        raise InstallError(f"{args[0]} failed:\n{result.stdout}{result.stderr}")
    return result


def succeeded(args: list[str], *, env=None) -> bool:
    result = command(args, env=env)
    return result is not None and result.returncode == 0


@dataclass
class Payload:
    source: Path | bytes
    mode: int = 0o644

    def sha256(self) -> str:
        if isinstance(self.source, Path):
            return digest(self.source)
        return hashlib.sha256(self.source).hexdigest()

    def size(self) -> int:
        return (self.source.stat().st_size if isinstance(self.source, Path)
                else len(self.source))


class Layout:
    def __init__(self):
        home = Path(os.environ.get("HOME", ""))
        self.roots = {
            "home": home,
            "data": Path(os.environ.get("XDG_DATA_HOME", str(home / ".local/share"))),
            "config": Path(os.environ.get("XDG_CONFIG_HOME", str(home / ".config"))),
        }
        for key, root in self.roots.items():
            if (not root.is_absolute() or root == Path("/") or
                    any(c in str(root) for c in "\n\r\t:$`\\\"%")):
                raise InstallError(f"Unsupported {key} directory: {root}")
            # XDG roots may deliberately be symlinks, but their descendants may not.
            resolved = root.resolve()
            if resolved == Path("/") or any(c in str(resolved) for c in "\n\r\t:$`\\\"%"):
                raise InstallError(f"Unsupported resolved {key} directory: {resolved}")
            self.roots[key] = resolved
        self.receipt = self.path("data/cassotis-ime/portable-install.json")

    def path(self, key: str) -> Path:
        relative_path(key)
        anchor, sep, name = key.partition("/")
        if not sep or anchor not in self.roots or not self.allowed(anchor, name):
            raise InstallError(f"Path is outside the Cassotis installation: {key}")
        root = self.roots[anchor]
        result = root / name
        current = result
        while current != root:
            if current.is_symlink():
                raise InstallError(f"Refusing a symlink destination: {current}")
            if current.exists() and current != result and not current.is_dir():
                raise InstallError(f"Not a directory: {current}")
            current = current.parent
        return result

    @staticmethod
    def allowed(anchor: str, name: str) -> bool:
        if anchor == "home":
            return (name.startswith(".local/libexec/cassotis-ime/") or
                    name == ".local/lib/fcitx5/libcassotis.so")
        if anchor == "data":
            return name in {
                "cassotis-ime/dict_sc.db", "cassotis-ime/dict_tc.db",
                "cassotis-ime/portable-install.json",
                "cassotis-ime/.portable-install.lock",
                "ibus/component/cassotis.xml", "fcitx5/addon/cassotis.conf",
                "fcitx5/inputmethod/cassotis.conf",
                "applications/ibus-setup-cassotis.desktop",
                "icons/hicolor/512x512/apps/cassotis-ime.png",
            } or name.startswith("doc/cassotis-ime/")
        return name in {
            "environment.d/80-cassotis-ibus.conf",
            "systemd/user/" + IBUS_SERVICE + ".d/80-cassotis-component-path.conf",
            "plasma-workspace/env/cassotis-ibus.sh",
        }

    def read_receipt(self) -> dict:
        if not self.receipt.exists():
            return {"format": FORMAT, "files": {}, "frameworks": []}
        receipt = json.loads(self.receipt.read_text(encoding="utf-8"))
        if receipt.get("format") != FORMAT:
            raise InstallError("Unknown user installation receipt format")
        if receipt.get("roots") != {k: str(v) for k, v in self.roots.items()}:
            raise InstallError("HOME/XDG directories differ from the installed receipt")
        if (not isinstance(receipt.get("files"), dict) or
                not isinstance(receipt.get("frameworks"), list) or
                any(f not in ("ibus", "fcitx5") for f in receipt["frameworks"])):
            raise InstallError("Invalid user installation receipt")
        for key, value in receipt["files"].items():
            self.path(key)
            if key.endswith(("/portable-install.json", "/.portable-install.lock")):
                raise InstallError("Receipt cannot manage its own control files")
            if not isinstance(value, str) or not re.fullmatch(r"[0-9a-f]{64}", value):
                raise InstallError(f"Invalid installed checksum: {key}")
        return receipt


def read_bundle(bundle: Path) -> dict[str, Path]:
    root = (bundle / "root").resolve()
    manifest = root / (DATA + "release-manifest.txt")
    checksums = root / (DATA + "release-sha256.txt")
    names = manifest.read_text(encoding="utf-8").splitlines()
    if len(names) != len(set(names)):
        raise InstallError("Duplicate bundle manifest entries")
    files = {}
    for name in names:
        relative_path(name)
        path = root / name
        if root not in path.resolve().parents or not path.is_file():
            raise InstallError(f"Invalid bundle file: {name}")
        files[name] = path
    expected = {}
    for line in checksums.read_text(encoding="utf-8").splitlines():
        match = re.fullmatch(r"([0-9a-f]{64}) [ *]\./(.+)", line)
        if not match:
            raise InstallError("Invalid bundle checksum manifest")
        name = relative_path(match[2])
        if name in expected:
            raise InstallError(f"Duplicate bundle checksum: {name}")
        expected[name] = match[1]
    if set(files) != set(expected):
        raise InstallError("Bundle file list does not match its checksum list")
    for name, path in files.items():
        if digest(path) != expected[name]:
            raise InstallError(f"Bundle checksum mismatch: {name}")
    return files


def choose_frameworks(requested: str, previous: dict) -> list[str]:
    if requested != "auto":
        result = ["ibus", "fcitx5"] if requested == "both" else [requested]
    elif previous.get("frameworks"):
        result = previous["frameworks"]
    else:
        available = [name for name in ("ibus", "fcitx5") if shutil.which(name)]
        desktop = os.environ.get("XDG_CURRENT_DESKTOP", "").lower()
        if "kde" in desktop and "fcitx5" in available:
            result = ["fcitx5"]
        elif "gnome" in desktop and "ibus" in available:
            result = ["ibus"]
        elif len(available) == 1:
            result = available
        else:
            raise InstallError("Select --framework ibus or --framework fcitx5. "
                               "A compatible desktop input framework must be installed first.")
    for name in result:
        if not shutil.which(name):
            raise InstallError(f"Missing {name}; this bundle does not include an input framework")
    return result


def version_tuple(value: str) -> tuple[int, ...]:
    match = re.search(r"\b(\d+)\.(\d+)\.(\d+)", value)
    if not match:
        raise InstallError(f"Cannot determine framework version: {value!r}")
    return tuple(map(int, match.groups()))


def check_elf(path: Path, machine: str) -> None:
    with path.open("rb") as stream:
        header = stream.read(20)
    expected = {"x86_64": 62, "aarch64": 183, "arm64": 183}.get(machine)
    if (expected is None or len(header) != 20 or header[:6] != b"\x7fELF\x02\x01" or
            int.from_bytes(header[18:20], "little") != expected):
        raise InstallError(f"Wrong binary architecture for {machine}: {path.name}")


def compatibility(files: dict[str, Path], frameworks: list[str]) -> str:
    # Some framework --version commands create configuration directories.
    # Preflight must not touch the desktop user's settings, even on failure.
    with tempfile.TemporaryDirectory(prefix="cassotis-preflight-") as scratch:
        environment = dict(os.environ, HOME=scratch, LC_ALL="C",
                           XDG_CONFIG_HOME=scratch + "/config",
                           XDG_DATA_HOME=scratch + "/data",
                           XDG_CACHE_HOME=scratch + "/cache")
        return check_runtime(files, frameworks, environment)


def check_runtime(files: dict[str, Path], frameworks: list[str], environment: dict) -> str:
    runtime = files[LIBEXEC + "cassotis-engine"].parent
    environment = dict(environment, LD_LIBRARY_PATH=str(runtime))
    candidates = [p for n, p in files.items() if n.startswith(LIBEXEC) and
                  not n.startswith(LIBEXEC + 'opencc/') and
                  (n.endswith(".so") or ".so." in n)]
    candidates.extend(files[LIBEXEC + n] for n in ("cassotis-engine", "cassotis-control"))
    if "ibus" in frameworks:
        candidates.append(files[LIBEXEC + "ibus-engine-cassotis"])
    if "fcitx5" in frameworks:
        candidates.append(find_addon(files))
        metadata = files["usr/share/fcitx5/addon/cassotis.conf"].read_text()
        required = re.search(r"(?m)^\d+=core:([^\r\n]+)$", metadata)
        if not required:
            raise InstallError("Fcitx bundle dependency version is missing")
        actual = command(["fcitx5", "--version"], env=environment, required=True)
        if version_tuple(actual.stdout) < version_tuple(required[1]):
            raise InstallError(f"Fcitx 5 {required[1]} or newer is required by this binary; "
                               f"installed: {actual.stdout.strip()}. Use a build for your distribution.")
    if not shutil.which("ldd"):
        raise InstallError("ldd is required to check binary compatibility before installation")
    failures = []
    for binary in dict.fromkeys(candidates):
        check_elf(binary, platform.machine())
        result = command(["ldd", "-r", str(binary)], env=environment, required=True)
        errors = [line.strip() for line in (result.stdout + result.stderr).splitlines()
                  if re.search(r"not found|undefined symbol|version .* not found", line)]
        if errors:
            failures.append(binary.name + ":\n  " + "\n  ".join(errors))
    if failures:
        raise InstallError("Incompatible or missing runtime libraries:\n" +
                           "\n".join(failures) + "\nUse a compatible build; moving files "
                           "or disabling filesystem protection cannot fix an ABI mismatch.")
    command([sys.executable, "-c", "import gi; gi.require_version('Gtk', '3.0'); "
             "from gi.repository import Gtk"], env=environment, required=True)
    command([sys.executable, "-c", "import ctypes; ctypes.CDLL('libsqlite3.so.0')"],
            env=environment, required=True)
    # These libraries are loaded dynamically by the engine, not listed by ldd.
    for name in ('libopencc.so', 'libmarisa.so'):
        private_library = runtime / 'opencc' / name
        if private_library.exists():
            check_elf(private_library, platform.machine())
    command([sys.executable, "-c", """
import ctypes
from pathlib import Path
import sys

def usable(lib, directory):
    lib.opencc_open.argtypes = [ctypes.c_char_p]
    lib.opencc_open.restype = ctypes.c_void_p
    lib.opencc_close.argtypes = [ctypes.c_void_p]
    lib.opencc_convert_utf8.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_size_t]
    lib.opencc_convert_utf8.restype = ctypes.c_void_p
    lib.opencc_convert_utf8_free.argtypes = [ctypes.c_void_p]
    samples = (('s2t.json', '\u6c49\u8bed', '\u6f22\u8a9e'), ('t2s.json', '\u6f22\u8a9e', '\u6c49\u8bed'))
    for config, source, expected in samples:
        path = str(directory / config) if directory else config
        handle = lib.opencc_open(path.encode())
        if handle in (None, ctypes.c_void_p(-1).value):
            return False
        output = None
        try:
            encoded = source.encode()
            output = lib.opencc_convert_utf8(handle, encoded, len(encoded))
            if not output or ctypes.string_at(output).decode() != expected:
                return False
        finally:
            if output:
                lib.opencc_convert_utf8_free(output)
            lib.opencc_close(handle)
    return True

for name in ('libopencc.so.1.1', 'libopencc.so.2', 'libopencc.so.1'):
    try:
        if usable(ctypes.CDLL(name), None):
            raise SystemExit(0)
    except (OSError, AttributeError):
        pass
directory = Path(sys.argv[1]) / 'opencc'
try:
    dependency = ctypes.CDLL(str(directory / 'libmarisa.so'))
    if usable(ctypes.CDLL(str(directory / 'libopencc.so')), directory):
        raise SystemExit(0)
except (OSError, AttributeError) as error:
    raise SystemExit('Incompatible OpenCC fallback: ' + str(error))
raise SystemExit('Missing or incompatible OpenCC conversion data')
""", str(runtime)], env=environment, required=True)
    version = command([str(runtime / "cassotis-engine"), "--version"], env=environment, required=True)
    return version.stdout.strip()


def find_addon(files: dict[str, Path]) -> Path:
    matches = [p for n, p in files.items()
               if n.startswith("usr/lib/") and n.endswith("/fcitx5/libcassotis.so")]
    if len(matches) != 1:
        raise InstallError("Bundle must contain exactly one native Fcitx 5 addon")
    return matches[0]


def ibus_component_path(layout: Layout) -> str:
    entries = [str(layout.path("data/ibus/component/cassotis.xml").parent)]
    entries += os.environ.get("IBUS_COMPONENT_PATH", "").split(":")
    entries += [str(Path(p) / "ibus/component") for p in
                os.environ.get("XDG_DATA_DIRS", "/usr/local/share:/usr/share").split(":") if p]
    entries = list(dict.fromkeys(p for p in entries if p))
    if any(not Path(p).is_absolute() or any(c in p for c in "\n\r\t$`\\\"%") for p in entries):
        raise InstallError("Unsupported IBus component search path")
    return ":".join(entries)


def desktop_quote(value: str) -> str:
    # Exec is a Desktop Entry command line, not a shell command.
    return '"' + value.replace("%", "%%").replace('"', '\\"') + '"'


def make_plan(files: dict[str, Path], layout: Layout, frameworks: list[str]) -> dict[str, Payload]:
    plan = {}
    for name, path in files.items():
        if name.startswith(LIBEXEC):
            leaf = name[len(LIBEXEC):]
            if leaf == "cassotis-refresh-sessions" or leaf.endswith("-smoke"):
                continue
            if leaf == "ibus-engine-cassotis" and "ibus" not in frameworks:
                continue
            plan["home/.local/libexec/cassotis-ime/" + leaf] = Payload(
                path, stat.S_IMODE(path.stat().st_mode) & 0o777)
        elif name in (DATA + "dict_sc.db", DATA + "dict_tc.db"):
            plan["data/cassotis-ime/" + path.name] = Payload(path)
        elif name.startswith(DOCS):
            plan["data/doc/cassotis-ime/" + name[len(DOCS):]] = Payload(path)
    icon = "icons/hicolor/512x512/apps/cassotis-ime.png"
    plan["data/" + icon] = Payload(files["usr/share/" + icon])
    setup = str(layout.path("home/.local/libexec/cassotis-ime/cassotis-settings"))
    desktop = files["usr/share/applications/ibus-setup-cassotis.desktop"].read_text(encoding="utf-8")
    desktop = re.sub(r"(?m)^Exec=.*$", lambda _: "Exec=" + desktop_quote(setup), desktop)
    plan["data/applications/ibus-setup-cassotis.desktop"] = Payload(desktop.encode())
    if "fcitx5" in frameworks:
        key = "home/.local/lib/fcitx5/libcassotis.so"
        plan[key] = Payload(find_addon(files), 0o755)
        metadata = files["usr/share/fcitx5/addon/cassotis.conf"].read_text(encoding="utf-8")
        metadata = re.sub(r"(?m)^Library=.*$", lambda _: "Library=" +
                          str(layout.path(key))[:-3], metadata)
        plan["data/fcitx5/addon/cassotis.conf"] = Payload(metadata.encode())
        plan["data/fcitx5/inputmethod/cassotis.conf"] = Payload(
            files["usr/share/fcitx5/inputmethod/cassotis.conf"])
    if "ibus" in frameworks:
        xml = ET.parse(files["usr/share/ibus/component/cassotis.xml"])
        executable = str(layout.path("home/.local/libexec/cassotis-ime/ibus-engine-cassotis"))
        xml.find("exec").text = shlex.quote(executable) + " --ibus"
        xml.find("engines/engine/setup").text = shlex.quote(setup)
        plan["data/ibus/component/cassotis.xml"] = Payload(
            ET.tostring(xml.getroot(), encoding="utf-8", xml_declaration=True))
        component_path = ibus_component_path(layout)
        plan["config/environment.d/80-cassotis-ibus.conf"] = Payload(
            ("IBUS_COMPONENT_PATH=" + component_path + "\n").encode())
        plan["config/plasma-workspace/env/cassotis-ibus.sh"] = Payload(
            ("#!/bin/sh\nexport IBUS_COMPONENT_PATH=" + shlex.quote(component_path) + "\n").encode(), 0o755)
        plan["config/systemd/user/" + IBUS_SERVICE + ".d/80-cassotis-component-path.conf"] = Payload(
            ('[Service]\nEnvironment="IBUS_COMPONENT_PATH=' + component_path + '"\n').encode())
    for key in plan:
        layout.path(key)
    return plan


def check_destinations(layout: Layout, plan: dict[str, Payload], previous: dict) -> None:
    old = previous["files"]
    space = {}
    for key in plan.keys() | old.keys():
        path = layout.path(key)
        if path.exists():
            if not path.is_file() or key not in old:
                raise InstallError(f"Not owned by this installer: {path}. "
                                   "Remove the older installation with its own uninstaller first.")
            if digest(path) != old[key]:
                raise InstallError(f"Installed file was modified; refusing to overwrite: {path}")
        parent = path.parent
        while not parent.exists():
            parent = parent.parent
        flags = os.statvfs(parent).f_flag
        if not os.access(parent, os.W_OK | os.X_OK) or flags & os.ST_RDONLY:
            raise InstallError(f"Installation directory is not writable: {parent}")
        if key.startswith("home/") and flags & os.ST_NOEXEC:
            raise InstallError(f"Runtime directory is on a noexec filesystem: {parent}")
        needed = (plan[key].size() if key in plan else 0) + (path.stat().st_size if path.exists() else 0)
        device = parent.stat().st_dev
        total, location = space.get(device, (0, parent))
        space[device] = (total + needed, location)
    for needed, location in space.values():
        if shutil.disk_usage(location).free < needed + 16 * 1024 * 1024:
            raise InstallError(f"Insufficient space for installation and rollback under {location}")
    for component in ("/usr/share/ibus/component/cassotis.xml",
                      "/usr/local/share/ibus/component/cassotis.xml",
                      "/usr/share/fcitx5/addon/cassotis.conf",
                      "/usr/local/share/fcitx5/addon/cassotis.conf"):
        if Path(component).exists():
            raise InstallError("A system Cassotis installation exists. Remove it with its "
                               "package manager/uninstaller before installing a user copy.")


class Transaction:
    """Atomic file replacement with rollback; never recursively removes user paths."""

    def __init__(self):
        self.changes: list[tuple[Path, Path | None]] = []
        self.directories: list[Path] = []

    def mkdir(self, path: Path) -> None:
        if path.exists():
            return
        self.mkdir(path.parent)
        path.mkdir(mode=0o755)
        self.directories.append(path)

    def replace(self, path: Path, payload: Payload | None) -> None:
        self.mkdir(path.parent)
        backup = None
        temporary = None
        registered = False
        try:
            if path.exists():
                fd, name = tempfile.mkstemp(prefix=".cassotis-backup-", dir=path.parent)
                os.close(fd)
                backup = Path(name)
                shutil.copy2(path, backup)
            self.changes.append((path, backup))
            registered = True
            if payload is not None:
                fd, name = tempfile.mkstemp(prefix=".cassotis-new-", dir=path.parent)
                temporary = Path(name)
                with os.fdopen(fd, "wb") as stream:
                    if isinstance(payload.source, Path):
                        with payload.source.open("rb") as source:
                            shutil.copyfileobj(source, stream, 1024 * 1024)
                    else:
                        stream.write(payload.source)
                    stream.flush()
                    os.fsync(stream.fileno())
                temporary.chmod(payload.mode)
                os.replace(temporary, path)
            else:
                path.unlink(missing_ok=True)
        except BaseException:
            if backup and not registered:
                backup.unlink(missing_ok=True)
            raise
        finally:
            if temporary:
                temporary.unlink(missing_ok=True)

    def finish(self, commit: bool) -> None:
        for path, backup in reversed(self.changes):
            if not commit:
                if backup is not None:
                    os.replace(backup, path)
                else:
                    path.unlink(missing_ok=True)
            elif backup is not None:
                backup.unlink()
        if not commit:
            for path in reversed(self.directories):
                try:
                    path.rmdir()
                except OSError:
                    pass


def stop_user_engine(layout: Layout) -> None:
    engine = layout.path("home/.local/libexec/cassotis-ime/cassotis-engine")
    adapter = layout.path("home/.local/libexec/cassotis-ime/ibus-engine-cassotis")
    processes = []
    for path in Path("/proc").glob("[0-9]*/exe"):
        try:
            if path.parent.stat().st_uid == os.getuid() and os.readlink(path).removesuffix(" (deleted)") in (str(engine), str(adapter)):
                processes.append(path)
        except OSError:
            continue
    if not processes:
        return
    control = layout.path("home/.local/libexec/cassotis-ime/cassotis-control")
    # Let a framework-owned adapter exit normally; no force-killing desktop apps.
    import signal
    for path in processes:
        try:
            if os.readlink(path).removesuffix(" (deleted)") == str(adapter):
                os.kill(int(path.parent.name), signal.SIGTERM)
        except OSError:
            pass
    environment = dict(os.environ, CASSOTIS_ENGINE_SOCKET=str(
        Path(os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")) /
        "cassotis-ime/engine.sock"))
    command([str(control), "shutdown"], env=environment, timeout=4)
    end = time.monotonic() + 3
    while time.monotonic() < end:
        if not any(p.exists() for p in processes):
            return
        time.sleep(0.05)
    raise InstallError("The installed engine is still running; finish composition and "
                       "stop Cassotis before retrying. No files have been replaced.")


def gnome_sources(add: bool) -> None:
    schema = "org.gnome.desktop.input-sources"
    for key in ("sources", "mru-sources"):
        writable = command(["gsettings", "writable", schema, key])
        if writable is None or writable.returncode or writable.stdout.strip() != "true":
            continue
        result = command(["gsettings", "get", schema, key])
        if result is None or result.returncode:
            continue
        try:
            items = ast.literal_eval(result.stdout.strip().removeprefix("@a(ss) "))
        except (ValueError, SyntaxError):
            continue
        item = ("ibus", "cassotis")
        if add and item not in items:
            items.append(item)
        if not add:
            items = [v for v in items if v != item]
        command(["gsettings", "set", schema, key, repr(items)])


def ibus_sources(add: bool) -> None:
    schema = 'org.freedesktop.ibus.general'
    key = 'preload-engines'
    result = command(['gsettings', 'get', schema, key])
    if result is None or result.returncode:
        return
    try:
        items = ast.literal_eval(result.stdout.strip().removeprefix('@as '))
    except (ValueError, SyntaxError):
        return
    if not isinstance(items, list) or any(not isinstance(item, str) for item in items):
        return
    if add and 'cassotis' not in items:
        items.append('cassotis')
    if not add:
        items = [item for item in items if item != 'cassotis']
    command(['gsettings', 'set', schema, key, repr(items)])


def refresh(layout: Layout, frameworks: list[str], *, previous_frameworks=(), no_refresh=False) -> None:
    affected = set(frameworks) | set(previous_frameworks)
    environment = dict(os.environ, IBUS_COMPONENT_PATH=ibus_component_path(layout))
    if "ibus" in affected:
        current = command(['ibus', 'engine'])
        selected = (current.stdout.strip() if current is not None and
                    current.returncode == 0 else '')
        command(["ibus", "write-cache"], env=environment)
    command(["update-desktop-database", str(layout.roots["data"] / "applications")])
    command(["gtk-update-icon-cache", "-q", "-t", str(layout.roots["data"] / "icons/hicolor")])
    if no_refresh:
        print("Session restart skipped. Restart your input framework (or log in again).")
        return
    if "ibus" in affected:
        command(["systemctl", "--user", "daemon-reload"])
        # New non-GNOME daemons inherit the user's component search path too.
        command(["systemctl", "--user", "set-environment",
                 "IBUS_COMPONENT_PATH=" + environment["IBUS_COMPONENT_PATH"]])
        saved = {}
        schema = "org.gnome.desktop.input-sources"
        for key in ("sources", "mru-sources", "current"):
            result = command(["gsettings", "get", schema, key])
            if result is not None and result.returncode == 0:
                saved[key] = result.stdout.strip()
        restarted = False
        if succeeded(["systemctl", "--user", "is-active", "--quiet", IBUS_SERVICE]):
            restarted = succeeded(["systemctl", "--user", "restart", IBUS_SERVICE], env=environment)
        elif succeeded(["ibus", "address"]):
            restarted = succeeded(["ibus", "restart"], env=environment)
        if restarted:
            end = time.monotonic() + 5
            while time.monotonic() < end:
                result = command(["ibus", "list-engine"], timeout=1, env=environment)
                if result is not None and result.returncode == 0:
                    found = bool(re.search(r"(?m)^\s*cassotis\s+-", result.stdout))
                    if found == ("ibus" in frameworks):
                        break
                time.sleep(0.1)
            else:
                print("Warning: IBus discovery has not completed; restart the desktop session.")
        # Preserve unrelated GNOME sources, MRU order and selection after discovery.
        for key, value in saved.items():
            command(["gsettings", "set", schema, key, value])
        gnome_sources("ibus" in frameworks)
        if 'gnome' not in os.environ.get('XDG_CURRENT_DESKTOP', '').lower():
            ibus_sources('ibus' in frameworks)
        if restarted and selected and (selected != 'cassotis' or 'ibus' in frameworks):
            command(['ibus', 'engine', selected], env=environment)
    if "fcitx5" in affected:
        helper = Path(__file__).with_name("fcitx5_profile.py")
        profile = layout.roots["config"] / "fcitx5/profile"
        if any(p.is_symlink() for p in (profile, profile.parent)):
            print("Warning: Fcitx profile is a symlink; add/remove Cassotis manually.")
        else:
            active = succeeded(["fcitx5-remote", "--check"])
            if active:
                command(["fcitx5-remote", "-e"])
                for _ in range(30):
                    if not succeeded(["fcitx5-remote", "--check"]):
                        break
                    time.sleep(0.1)
                else:
                    print("Warning: Fcitx 5 is still running; restart it and configure Cassotis manually.")
                    return
            if "fcitx5" in frameworks or profile.exists():
                result = command([sys.executable, str(helper),
                                  "add" if "fcitx5" in frameworks else "remove", str(profile)])
                if result is None or result.returncode:
                    print("Warning: configure Cassotis in the Fcitx 5 input-method list manually.")
            if active:
                command(["fcitx5", "-d"])
    if frameworks:
        print("Choose Cassotis in your desktop input framework. If it was not refreshed, restart it.")


def apply_plan(layout: Layout, plan: dict[str, Payload], previous: dict,
               frameworks: list[str], version: str) -> None:
    hashes = {key: value.sha256() for key, value in plan.items()}
    receipt = {"format": FORMAT, "version": version, "frameworks": frameworks,
               "roots": {key: str(value) for key, value in layout.roots.items()},
               "files": hashes}
    tx = Transaction()
    try:
        for key, payload in plan.items():
            path = layout.path(key)
            if (not path.exists() or previous["files"].get(key) != hashes[key] or
                    stat.S_IMODE(path.stat().st_mode) != payload.mode):
                tx.replace(path, payload)
        for key in previous["files"].keys() - plan.keys():
            tx.replace(layout.path(key), None)
        tx.replace(layout.receipt, Payload((json.dumps(receipt, indent=2) + "\n").encode(), 0o600))
    except BaseException:
        tx.finish(False)
        raise
    tx.finish(True)


def uninstall(layout: Layout, previous: dict, *, no_refresh: bool) -> None:
    retained = {}
    tx = Transaction()
    try:
        for key, expected in previous["files"].items():
            path = layout.path(key)
            if path.is_file() and digest(path) == expected:
                tx.replace(path, None)
            elif path.exists():
                print(f"Warning: retaining modified file: {path}")
                retained[key] = expected
        if retained:
            updated = dict(previous, files=retained)
            tx.replace(layout.receipt, Payload((json.dumps(updated, indent=2) + "\n").encode(), 0o600))
        else:
            tx.replace(layout.receipt, None)
    except BaseException:
        tx.finish(False)
        raise
    tx.finish(True)
    directories = {layout.path(key).parent for key in previous["files"]}
    # Only prune package-owned subdirectories; never remove shared XDG roots.
    stops = set(layout.roots.values()) | {
        layout.roots["data"] / "cassotis-ime",
        layout.roots["home"] / ".local/libexec",
        layout.roots["home"] / ".local/lib/fcitx5",
        layout.roots["data"] / "doc",
        layout.roots["config"] / "systemd/user",
    }
    for directory in sorted(directories, key=lambda p: len(p.parts), reverse=True):
        while directory not in stops:
            try:
                directory.rmdir()
            except OSError:
                break
            directory = directory.parent
    refresh(layout, [], previous_frameworks=previous["frameworks"], no_refresh=no_refresh)
    print("User installation removed. User dictionary, settings and unlisted files were retained.")
    if retained:
        raise InstallError("Modified package files remain; see warnings above")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=("install", "uninstall"))
    parser.add_argument("--bundle", type=Path, required=True)
    parser.add_argument("--framework", choices=("auto", "ibus", "fcitx5", "both"), default="auto")
    parser.add_argument("--check", action="store_true", help="Read-only compatibility and destination check")
    parser.add_argument("--no-refresh", action="store_true", help="Do not restart or enable input frameworks")
    args = parser.parse_args()
    if sys.platform != "linux" or os.geteuid() == 0:
        raise InstallError("Run --user on Linux as the desktop user, WITHOUT sudo or su")
    if os.environ.get("DESTDIR"):
        raise InstallError("--user cannot be combined with DESTDIR (staging is not a live installation)")
    layout = Layout()
    previous = layout.read_receipt()
    if args.action == "uninstall" and not layout.receipt.exists():
        print("No managed user installation found; no files were removed.")
        return 0
    if args.action == "install":
        files = read_bundle(args.bundle)
        frameworks = choose_frameworks(args.framework, previous)
        version = compatibility(files, frameworks)
        plan = make_plan(files, layout, frameworks)
        check_destinations(layout, plan, previous)
        print(f"Compatible {platform.machine()} bundle {version}; frameworks: {', '.join(frameworks)}")
        print(f"Runtime: {layout.roots['home'] / '.local/libexec/cassotis-ime'}")
        print(f"Dictionary: {layout.roots['data'] / 'cassotis-ime'}")
    if args.check:
        print("Check passed. No installation files or desktop settings were changed.")
        return 0
    lock_path = layout.path("data/cassotis-ime/.portable-install.lock")
    lock_path.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    with lock_path.open("a") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError as exc:
            raise InstallError("Another Cassotis user installer is running") from exc
        if layout.read_receipt() != previous:
            raise InstallError("Installation changed during preflight; retry")
        stop_user_engine(layout)
        if args.action == "install":
            apply_plan(layout, plan, previous, frameworks, version)
            refresh(layout, frameworks, previous_frameworks=previous["frameworks"], no_refresh=args.no_refresh)
            print("User installation complete. No system directories were modified.")
        else:
            uninstall(layout, previous, no_refresh=args.no_refresh)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (InstallError, OSError, ValueError, KeyError) as error:
        print(f"Error: {error}", file=sys.stderr)
        raise SystemExit(1)
