#!/usr/bin/env python3

"""Add or remove Cassotis without replacing unrelated Fcitx 5 profile data."""

from __future__ import annotations

import argparse
import os
import re
import stat
import tempfile
from dataclasses import dataclass
from pathlib import Path


SECTION_RE = re.compile(r"^\[([^\]\r\n]+)\]\s*$")
GROUP_RE = re.compile(r"^Groups/(\d+)$")
ITEM_RE = re.compile(r"^Groups/(\d+)/Items/(\d+)$")
KEY_RE = re.compile(r"^([^#;=][^=]*)=(.*)$")


@dataclass
class Block:
    name: str | None
    lines: list[str]

    def value(self, key: str) -> str | None:
        for line in self.lines[1:] if self.name is not None else self.lines:
            match = KEY_RE.match(line.rstrip("\r\n"))
            if match and match.group(1).strip() == key:
                return match.group(2).strip()
        return None

    def replace_value(self, key: str, value: str) -> None:
        start = 1 if self.name is not None else 0
        for index in range(start, len(self.lines)):
            line = self.lines[index]
            match = KEY_RE.match(line.rstrip("\r\n"))
            if match and match.group(1).strip() == key:
                newline = "\r\n" if line.endswith("\r\n") else "\n"
                self.lines[index] = f"{match.group(1)}={value}{newline}"
                return


def parse_blocks(text: str) -> list[Block]:
    blocks: list[Block] = []
    current = Block(None, [])
    for line in text.splitlines(keepends=True):
        match = SECTION_RE.match(line.rstrip("\r\n"))
        if match:
            if current.lines:
                blocks.append(current)
            current = Block(match.group(1), [line])
        else:
            current.lines.append(line)
    if current.lines:
        blocks.append(current)
    return blocks


def render_blocks(blocks: list[Block]) -> str:
    return "".join(line for block in blocks for line in block.lines)


def new_profile() -> str:
    return """[Groups/0]
Name=Default
Default Layout=us
DefaultIM=cassotis

[Groups/0/Items/0]
Name=keyboard-us
Layout=

[Groups/0/Items/1]
Name=cassotis
Layout=

[GroupOrder]
0=Default
"""


def find_target_group(blocks: list[Block]) -> int | None:
    groups: dict[int, str] = {}
    ordered_names: list[tuple[int, str]] = []
    for block in blocks:
        if block.name is None:
            continue
        group_match = GROUP_RE.match(block.name)
        if group_match:
            name = block.value("Name")
            if name is not None:
                groups[int(group_match.group(1))] = name
        elif block.name == "GroupOrder":
            for line in block.lines[1:]:
                match = KEY_RE.match(line.rstrip("\r\n"))
                if match and match.group(1).strip().isdigit():
                    ordered_names.append(
                        (int(match.group(1).strip()), match.group(2).strip())
                    )
    for _, name in sorted(ordered_names):
        for index, group_name in groups.items():
            if group_name == name:
                return index
    return min(groups) if groups else None


def add_cassotis(text: str) -> tuple[str, bool]:
    if not text.strip():
        return new_profile(), True
    blocks = parse_blocks(text)
    for block in blocks:
        if block.name is not None and ITEM_RE.match(block.name):
            if block.value("Name") == "cassotis":
                return text, False

    group_index = find_target_group(blocks)
    if group_index is None:
        separator = "" if text.endswith("\n") else "\n"
        return text + separator + "\n" + new_profile(), True

    item_indices = []
    for block in blocks:
        if block.name is None:
            continue
        match = ITEM_RE.match(block.name)
        if match and int(match.group(1)) == group_index:
            item_indices.append(int(match.group(2)))
    item_index = max(item_indices, default=-1) + 1
    separator = "" if text.endswith("\n") else "\n"
    addition = (
        f"{separator}\n[Groups/{group_index}/Items/{item_index}]\n"
        "Name=cassotis\nLayout=\n"
    )
    return text + addition, True


def remove_cassotis(text: str) -> tuple[str, bool]:
    blocks = parse_blocks(text)
    removed = False
    kept_by_group: dict[int, list[Block]] = {}
    output: list[Block] = []

    for block in blocks:
        match = ITEM_RE.match(block.name or "")
        if match and block.value("Name") == "cassotis":
            removed = True
            continue
        if match:
            kept_by_group.setdefault(int(match.group(1)), []).append(block)
        output.append(block)
    if not removed:
        return text, False

    next_index: dict[int, int] = {}
    for block in output:
        match = ITEM_RE.match(block.name or "")
        if not match:
            continue
        group_index = int(match.group(1))
        item_index = next_index.get(group_index, 0)
        next_index[group_index] = item_index + 1
        block.name = f"Groups/{group_index}/Items/{item_index}"
        newline = "\r\n" if block.lines[0].endswith("\r\n") else "\n"
        block.lines[0] = f"[{block.name}]{newline}"

    fallback_by_group = {
        group: next(
            (item.value("Name") for item in items if item.value("Name")),
            "keyboard-us",
        )
        for group, items in kept_by_group.items()
    }
    for block in output:
        match = GROUP_RE.match(block.name or "")
        if match and block.value("DefaultIM") == "cassotis":
            group_index = int(match.group(1))
            block.replace_value(
                "DefaultIM", fallback_by_group.get(group_index, "keyboard-us")
            )
    return render_blocks(output), True


def atomic_write(path: Path, text: str) -> None:
    path.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    old_mode = stat.S_IMODE(path.stat().st_mode) if path.exists() else 0o600
    descriptor, temporary_name = tempfile.mkstemp(
        prefix=".cassotis-profile.", dir=path.parent
    )
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8", newline="") as stream:
            stream.write(text)
            stream.flush()
            os.fsync(stream.fileno())
        os.chmod(temporary_name, old_mode)
        os.replace(temporary_name, path)
    finally:
        try:
            os.unlink(temporary_name)
        except FileNotFoundError:
            pass


def self_test() -> None:
    original = """# keep this comment
[Groups/0]
Name=Default
Default Layout=us
DefaultIM=pinyin

[Groups/0/Items/0]
Name=keyboard-us
Layout=

[Groups/0/Items/1]
Name=pinyin
Layout=

[GroupOrder]
0=Default
"""
    added, changed = add_cassotis(original)
    assert changed
    assert "# keep this comment" in added
    assert "[Groups/0/Items/2]\nName=cassotis" in added
    assert add_cassotis(added) == (added, False)
    removed, changed = remove_cassotis(added)
    assert changed
    assert removed.rstrip("\n") == original.rstrip("\n")

    created, changed = add_cassotis("")
    assert changed and "DefaultIM=cassotis" in created
    removed, changed = remove_cassotis(created)
    assert changed
    assert "Name=cassotis" not in removed
    assert "DefaultIM=keyboard-us" in removed


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("action", choices=("add", "remove", "self-test"))
    parser.add_argument("profile", nargs="?", type=Path)
    arguments = parser.parse_args()

    if arguments.action == "self-test":
        self_test()
        return 0
    if arguments.profile is None:
        parser.error("profile is required for add/remove")

    path = arguments.profile.expanduser()
    original = path.read_text(encoding="utf-8") if path.exists() else ""
    updated, changed = (
        add_cassotis(original)
        if arguments.action == "add"
        else remove_cassotis(original)
    )
    if changed:
        atomic_write(path, updated)
    print("changed=1" if changed else "changed=0")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
