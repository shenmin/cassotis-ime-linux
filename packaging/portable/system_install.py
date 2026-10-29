#!/usr/bin/env python3

"""Install payload files without importing the bundle's filesystem metadata."""

import argparse
import os
from pathlib import Path
import shutil
import stat
import subprocess
import sys
import tempfile


class InstallError(Exception):
    pass


def check_directory(path):
    if path.is_symlink() or (path.exists() and not path.is_dir()):
        raise InstallError(f"destination directory is not a real directory: {path}")


def plan_files(source, destination):
    if source.is_symlink() or not (source / "usr").is_dir():
        raise InstallError(f"release root is missing or unsafe: {source}")
    for path in (destination, *destination.parents):
        check_directory(path)
    entries = []
    for path in sorted(source.rglob("*"), key=lambda p: (len(p.parts), str(p))):
        relative = path.relative_to(source)
        if relative.parts[0] != "usr":
            raise InstallError(f"unexpected payload path: {relative}")
        mode = path.lstat().st_mode
        if stat.S_ISLNK(mode):
            link = Path(os.readlink(path))
            resolved = path.resolve()
            if link.is_absolute() or not resolved.is_relative_to(source) or not resolved.is_file():
                raise InstallError(f"unsafe payload symlink: {relative}")
        elif not (stat.S_ISDIR(mode) or stat.S_ISREG(mode)):
            raise InstallError(f"unsupported payload entry: {relative}")
        target = destination / relative
        check_directory(target.parent)
        if stat.S_ISDIR(mode):
            check_directory(target)
        elif target.exists() and not (target.is_symlink() or target.is_file()):
            raise InstallError(f"destination file conflicts with another entry: {target}")
        entries.append((path, target, mode))
    return entries


def selinux_restore_command(destination):
    # A staging tree must not acquire the build host's path-based labels.
    if destination != Path("/") or not Path("/sys/fs/selinux/enforce").exists():
        return None
    restorecon = shutil.which("restorecon")
    if not restorecon:
        raise InstallError("SELinux is enabled but restorecon is missing; install policycoreutils first")
    return restorecon


def ensure_directory(path, created):
    check_directory(path)
    if path.is_dir():
        return
    ensure_directory(path.parent, created)
    path.mkdir(mode=0o755)
    if os.geteuid() == 0:
        os.chown(path, 0, 0)
    path.chmod(0o755)
    created.append(path)


def install_file(source, target, mode):
    # Replacement also avoids following a previous symlink or modifying another
    # file through a hard link. Never copy ownership, ACLs or xattrs from HOME.
    fd, name = tempfile.mkstemp(prefix=".cassotis-", dir=target.parent)
    temporary = Path(name)
    try:
        with os.fdopen(fd, "wb") as stream:
            if not stat.S_ISLNK(mode):
                with source.open("rb") as contents:
                    shutil.copyfileobj(contents, stream)
                if os.geteuid() == 0:
                    os.fchown(stream.fileno(), 0, 0)
                os.fchmod(stream.fileno(), 0o755 if mode & 0o111 else 0o644)
        if stat.S_ISLNK(mode):
            temporary.unlink()
            temporary.symlink_to(os.readlink(source))
            if os.geteuid() == 0:
                os.chown(temporary, 0, 0, follow_symlinks=False)
        os.replace(temporary, target)
    finally:
        temporary.unlink(missing_ok=True)


def restore_labels(command, paths):
    # No recursion: existing system directories and unlisted files are excluded.
    for start in range(0, len(paths), 128):
        subprocess.run([command, "-F", "--", *(str(p) for p in paths[start:start + 128])],
                       check=True, timeout=30)


def install_tree(source, destination):
    source = Path(source).absolute()
    destination = Path(os.path.abspath(destination))
    if destination == Path("/") and os.geteuid() != 0:
        raise InstallError("system installation requires root")
    if destination != Path("/") and (source.is_relative_to(destination) or destination.is_relative_to(source)):
        raise InstallError("source and destination trees must not overlap")
    # Validate the complete tree and required tools before writing any payload.
    entries = plan_files(source, destination)
    restorecon = selinux_restore_command(destination)
    created = []
    installed = []
    ensure_directory(destination, created)
    for source_file, target, mode in entries:
        if stat.S_ISDIR(mode):
            ensure_directory(target, created)
        else:
            install_file(source_file, target, mode)
            installed.append(target)
    if restorecon:
        restore_labels(restorecon, created + installed)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", required=True, type=Path)
    parser.add_argument("--destination", required=True, type=Path)
    args = parser.parse_args()
    try:
        install_tree(args.source, args.destination)
    except (InstallError, OSError, ValueError, RuntimeError, subprocess.SubprocessError) as error:
        print(f"Error: system installation failed: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
