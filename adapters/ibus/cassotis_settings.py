#!/usr/bin/env python3

import argparse
import os
import re
import subprocess
import sys
import threading

import gi

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
from gi.repository import Gdk, Gio, GLib, Gtk, Pango


BASE_STATE_KEYS = (
    "input_mode",
    "dictionary_variant",
    "pinyin_scheme",
    "fuzzy_pinyin_enabled",
    "fuzzy_pinyin_rules",
    "full_width_mode",
    "punctuation_full_width",
    "candidate_page_key_scheme",
    "one_key_completion_key",
    "candidate_page_size",
    "debug_mode",
)

SHORTCUTS = (
    ("input_mode", "中英文切换"),
    ("punctuation", "中英文标点切换"),
    ("dictionary", "简繁切换"),
    ("full_width", "全角/半角切换"),
    ("settings", "打开设置"),
)

SHORTCUT_STATE_KEYS = (
    "shortcut_input_mode_key",
    "shortcut_input_mode_modifiers",
    "shortcut_punctuation_key",
    "shortcut_punctuation_modifiers",
    "shortcut_dictionary_key",
    "shortcut_dictionary_modifiers",
    "shortcut_full_width_key",
    "shortcut_full_width_modifiers",
    "shortcut_settings_key",
    "shortcut_settings_modifiers",
)

STATE_KEYS = BASE_STATE_KEYS + SHORTCUT_STATE_KEYS

SCHEME_NAMES = (
    "全拼",
    "微软双拼",
    "小鹤双拼",
    "自然码双拼",
    "搜狗双拼",
    "紫光双拼",
    "拼音加加双拼",
)

FUZZY_RULES = (
    "z / zh",
    "c / ch",
    "s / sh",
    "l / n",
    "f / h",
    "r / l",
    "an / ang",
    "en / eng",
    "in / ing",
    "ian / iang",
    "uan / uang",
)

PAGE_KEY_SCHEMES = (
    "- / =（减号 / 等号）",
    "[ / ]（方括号）",
    ", / .（逗号 / 句号）",
    "Shift+Tab / Tab",
)

PAGE_KEY_PREVIEWS = (
    ("-", "="),
    ("[", "]"),
    (",", "."),
    ("Shift+Tab", "Tab"),
)

COMPLETION_KEYS = ("Tab", "`")

CONTROL_TIMEOUT_SECONDS = 35
ENGINE_VERSION_TIMEOUT_SECONDS = 2
PROJECT_URL = "https://www.yanquan.org/linux"
ENGINE_VERSION_PATTERN = re.compile(
    r"[0-9]+(?:\.[0-9]+){2}(?:[.-][0-9A-Za-z.-]+)?"
)

MODIFIER_CHOICES = (
    (0, "无"),
    (1, "Shift"),
    (2, "Ctrl"),
    (4, "Alt"),
    (3, "Ctrl + Shift"),
    (6, "Ctrl + Alt"),
    (5, "Alt + Shift"),
    (7, "Ctrl + Shift + Alt"),
)

KEY_CHOICES = (
    (0x08, "Backspace"),
    (0x09, "Tab"),
    (0x0D, "Enter"),
    (0x10, "Shift"),
    (0x1B, "Esc"),
    (0x20, "Space"),
    (0x21, "Page Up"),
    (0x22, "Page Down"),
    (0x23, "End"),
    (0x24, "Home"),
    (0x25, "Left"),
    (0x26, "Up"),
    (0x27, "Right"),
    (0x28, "Down"),
    (0x2D, "Insert"),
    (0x2E, "Delete"),
    (0x6A, "NumpadMultiply"),
    (0x6B, "NumpadPlus"),
    (0x6D, "NumpadMinus"),
    (0x6E, "NumpadDecimal"),
    (0x6F, "NumpadDivide"),
) + tuple((ord(digit), digit) for digit in "0123456789") + tuple(
    (ord(letter), letter) for letter in "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
) + tuple(
    (0x70 + index, f"F{index + 1}") for index in range(24)
) + (
    (0xBA, ";"),
    (0xBB, "="),
    (0xBC, ","),
    (0xBD, "-"),
    (0xBE, "."),
    (0xBF, "/"),
    (0xC0, "`"),
    (0xDB, "["),
    (0xDC, "\\"),
    (0xDD, "]"),
    (0xDE, "'"),
)

DEFAULT_STATE = {
    "input_mode": 0,
    "dictionary_variant": 0,
    "pinyin_scheme": 0,
    "fuzzy_pinyin_enabled": 0,
    "fuzzy_pinyin_rules": 0,
    "full_width_mode": 0,
    "punctuation_full_width": 1,
    "candidate_page_key_scheme": 0,
    "one_key_completion_key": 0,
    "candidate_page_size": 9,
    "debug_mode": 0,
    "shortcut_input_mode_key": 0x10,
    "shortcut_input_mode_modifiers": 0,
    "shortcut_punctuation_key": 0xBE,
    "shortcut_punctuation_modifiers": 2,
    "shortcut_dictionary_key": ord("T"),
    "shortcut_dictionary_modifiers": 3,
    "shortcut_full_width_key": 0x20,
    "shortcut_full_width_modifiers": 1,
    "shortcut_settings_key": 0x79,
    "shortcut_settings_modifiers": 3,
}

PAGE_DEFAULT_KEYS = (
    (
        "input_mode",
        "dictionary_variant",
        "pinyin_scheme",
        "full_width_mode",
        "punctuation_full_width",
    ),
    ("candidate_page_size",),
    ("fuzzy_pinyin_enabled", "fuzzy_pinyin_rules"),
    (
        "candidate_page_key_scheme",
        "one_key_completion_key",
        *SHORTCUT_STATE_KEYS,
    ),
    ("debug_mode",),
)


class ControlError(RuntimeError):
    pass


def default_control_path():
    return os.path.join(os.path.dirname(os.path.realpath(__file__)),
                        "cassotis-control")


def default_engine_path():
    configured_path = os.environ.get("CASSOTIS_ENGINE_PATH")
    if configured_path:
        return configured_path
    return os.path.join(os.path.dirname(os.path.realpath(__file__)),
                        "cassotis-engine")


def read_engine_version(engine_path):
    try:
        result = subprocess.run(
            [engine_path, "--version"],
            check=False,
            capture_output=True,
            text=True,
            timeout=ENGINE_VERSION_TIMEOUT_SECONDS,
        )
    except (OSError, subprocess.SubprocessError):
        return ""
    version = result.stdout.strip()
    if result.returncode != 0 or not ENGINE_VERSION_PATTERN.fullmatch(version):
        return ""
    return version


def settings_subtitle(engine_path):
    version = read_engine_version(engine_path)
    version_text = f"v{version}" if version else "v?"
    return f"Cassotis IME - 言泉输入法 ({version_text})"


def run_control(control_path, arguments):
    try:
        result = subprocess.run(
            [control_path, *arguments],
            check=False,
            capture_output=True,
            text=True,
            timeout=CONTROL_TIMEOUT_SECONDS,
        )
    except (OSError, subprocess.SubprocessError) as error:
        raise ControlError(str(error)) from error
    if result.returncode != 0:
        message = result.stderr.strip() or result.stdout.strip()
        raise ControlError(message or "设置服务没有响应")
    return result.stdout


def shortcut_is_valid(key_code, modifiers):
    if not 0 < key_code <= 0xFFFF or modifiers & ~7:
        return False
    if key_code == 0x10:
        return modifiers == 0
    if key_code in (0x11, 0x12):
        return False
    return modifiers != 0 or 0x70 <= key_code <= 0x87


def validate_state(state):
    missing = [key for key in STATE_KEYS if key not in state]
    if missing:
        raise ControlError("设置状态缺少字段：" + ", ".join(missing))
    if state["input_mode"] not in (0, 1):
        raise ControlError("输入模式超出范围")
    if state["dictionary_variant"] not in (0, 1):
        raise ControlError("词库模式超出范围")
    if not 0 <= state["pinyin_scheme"] < len(SCHEME_NAMES):
        raise ControlError("拼音方案超出范围")
    if state["fuzzy_pinyin_enabled"] not in (0, 1):
        raise ControlError("模糊音开关超出范围")
    if state["fuzzy_pinyin_rules"] & ~((1 << len(FUZZY_RULES)) - 1):
        raise ControlError("模糊音规则超出范围")
    if state["full_width_mode"] not in (0, 1) or \
            state["punctuation_full_width"] not in (0, 1):
        raise ControlError("字符模式超出范围")
    if not 0 <= state["candidate_page_key_scheme"] < len(PAGE_KEY_SCHEMES):
        raise ControlError("候选翻页方案超出范围")
    if not 0 <= state["one_key_completion_key"] < len(COMPLETION_KEYS):
        raise ControlError("一键补全按键超出范围")
    if not 3 <= state["candidate_page_size"] <= 9:
        raise ControlError("每页候选数必须为 3 到 9")
    if state["debug_mode"] not in (0, 1):
        raise ControlError("调试模式超出范围")
    if state["candidate_page_key_scheme"] == 3 and \
            state["one_key_completion_key"] == 0:
        raise ControlError("Tab 用于一键补全时，不能同时用于候选翻页")

    shortcuts = []
    for prefix, _caption in SHORTCUTS:
        key_code = state[f"shortcut_{prefix}_key"]
        modifiers = state[f"shortcut_{prefix}_modifiers"]
        if not shortcut_is_valid(key_code, modifiers):
            raise ControlError(f"“{_caption}”快捷键无效")
        shortcuts.append((key_code, modifiers, _caption))
    seen = {}
    for key_code, modifiers, caption in shortcuts:
        signature = (key_code, modifiers)
        if signature in seen:
            raise ControlError(f"“{caption}”与“{seen[signature]}”快捷键重复")
        seen[signature] = caption
    return state


def parse_state(output):
    state = {}
    for line in output.splitlines():
        key, separator, value = line.partition("=")
        if separator and key in STATE_KEYS:
            try:
                state[key] = int(value)
            except ValueError as error:
                raise ControlError(f"无效的设置值：{line}") from error
    return validate_state(state)


def get_state(control_path):
    return parse_state(run_control(control_path, ["get-state"]))


def set_state(control_path, state):
    validate_state(state)
    arguments = ["set-state"] + [str(state[key]) for key in STATE_KEYS]
    return parse_state(run_control(control_path, arguments))


def clear_user_dictionary(control_path):
    run_control(control_path, ["clear-user-dictionary"])
    return get_state(control_path)


def default_data_directory():
    data_home = os.environ.get("XDG_DATA_HOME")
    if not data_home:
        data_home = os.path.join(os.path.expanduser("~"), ".local", "share")
    return os.path.join(data_home, "cassotis-ime")


def merge_visible_state(current, changes):
    state = dict(current)
    state.update(changes)
    return validate_state(state)


class SettingsWindow(Gtk.ApplicationWindow):
    def __init__(self, application, control_path, engine_path):
        super().__init__(application=application)
        self.control_path = control_path
        self.current_dictionary_variant = 0
        self.loaded_state = dict(DEFAULT_STATE)
        self.shortcut_widgets = {}
        self.operation_serial = 0
        self.closed = False
        self.set_title("设置")
        self.set_default_size(760, 560)
        self.set_icon_name("input-keyboard")

        header = Gtk.HeaderBar()
        header.set_show_close_button(True)
        header.set_title("设置")
        header.set_subtitle(settings_subtitle(engine_path))
        self.set_titlebar(header)

        root = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        self.add(root)
        self.notebook = Gtk.Notebook()
        root.pack_start(self.notebook, True, True, 0)
        self.notebook.append_page(
            self._build_general_page(), Gtk.Label(label="常规")
        )
        self.notebook.append_page(
            self._build_appearance_page(), Gtk.Label(label="外观")
        )
        self.notebook.append_page(
            self._build_fuzzy_page(), Gtk.Label(label="模糊拼音")
        )
        self.notebook.append_page(
            self._build_shortcuts_page(), Gtk.Label(label="快捷键")
        )
        self.notebook.append_page(
            self._build_advanced_page(), Gtk.Label(label="高级")
        )

        footer = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        footer.set_border_width(12)
        root.pack_end(footer, False, False, 0)
        self.defaults_button = Gtk.Button(label="恢复默认")
        self.defaults_button.connect("clicked", self._restore_defaults)
        footer.pack_start(self.defaults_button, False, False, 0)
        website_link = Gtk.LinkButton.new_with_label(PROJECT_URL, PROJECT_URL)
        footer.pack_start(website_link, False, False, 0)
        self.status = Gtk.Label(label="")
        self.status.set_xalign(0)
        footer.pack_start(self.status, True, True, 6)
        self.cancel_button = Gtk.Button(label="取消")
        self.cancel_button.connect("clicked", self._cancel)
        footer.pack_end(self.cancel_button, False, False, 0)
        self.ok_button = Gtk.Button(label="确定")
        self.ok_button.get_style_context().add_class("suggested-action")
        self.ok_button.connect("clicked", self._ok)
        footer.pack_end(self.ok_button, False, False, 0)
        self.apply_button = Gtk.Button(label="应用")
        self.apply_button.connect("clicked", self._apply)
        footer.pack_end(self.apply_button, False, False, 0)

        self._show_state(DEFAULT_STATE)
        self.connect("destroy", self._on_destroy)
        GLib.idle_add(self._load)

    @staticmethod
    def _new_page():
        scroller = Gtk.ScrolledWindow()
        scroller.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        content = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=18)
        content.set_border_width(24)
        scroller.add(content)
        return scroller, content

    @staticmethod
    def _new_section(title):
        frame = Gtk.Frame(label=title)
        grid = Gtk.Grid(column_spacing=24, row_spacing=12)
        grid.set_border_width(14)
        frame.add(grid)
        frame._cassotis_grid = grid
        return frame

    @staticmethod
    def _redirect_combo_scroll(combo, event):
        parent = combo.get_parent()
        while parent is not None and not isinstance(parent, Gtk.ScrolledWindow):
            parent = parent.get_parent()
        if parent is None:
            return True

        adjustment = parent.get_vadjustment()
        step = adjustment.get_step_increment()
        if step <= 0:
            step = 40.0
        if event.direction == Gdk.ScrollDirection.UP:
            delta = -step * 3
        elif event.direction == Gdk.ScrollDirection.DOWN:
            delta = step * 3
        elif event.direction == Gdk.ScrollDirection.SMOOTH:
            delta = getattr(event, "delta_y", 0.0) * step * 3
        else:
            return True

        lower = adjustment.get_lower()
        upper = max(lower, adjustment.get_upper() - adjustment.get_page_size())
        adjustment.set_value(
            min(upper, max(lower, adjustment.get_value() + delta))
        )
        return True

    @staticmethod
    def _protect_combo_from_scroll(combo):
        combo.add_events(
            Gdk.EventMask.SCROLL_MASK | Gdk.EventMask.SMOOTH_SCROLL_MASK
        )
        combo.connect("scroll-event", SettingsWindow._redirect_combo_scroll)
        return combo

    @staticmethod
    def _combo(values):
        combo = Gtk.ComboBoxText()
        for index, value in enumerate(values):
            combo.append(str(index), value)
        combo.set_hexpand(True)
        return SettingsWindow._protect_combo_from_scroll(combo)

    @staticmethod
    def _choice_combo(choices):
        combo = Gtk.ComboBoxText()
        for value, caption in choices:
            combo.append(str(value), caption)
        combo.set_hexpand(True)
        return SettingsWindow._protect_combo_from_scroll(combo)

    @staticmethod
    def _add_row(frame, row, label_text, widget):
        label = Gtk.Label(label=label_text)
        label.set_xalign(0)
        frame._cassotis_grid.attach(label, 0, row, 1, 1)
        frame._cassotis_grid.attach(widget, 1, row, 1, 1)

    def _build_general_page(self):
        page, content = self._new_page()
        general = self._new_section("输入")
        content.pack_start(general, False, False, 0)
        self.input_mode = self._combo(
            ("简体中文输入", "繁体中文输入", "英文输入")
        )
        self._add_row(general, 0, "输入模式", self.input_mode)
        self.pinyin_scheme = self._combo(SCHEME_NAMES)
        self._add_row(general, 1, "拼音方案", self.pinyin_scheme)

        typography = self._new_section("字符与标点")
        content.pack_start(typography, False, False, 0)
        self.punctuation = self._combo(("中文标点", "英文标点"))
        self._add_row(typography, 0, "标点", self.punctuation)
        self.full_width = Gtk.CheckButton(label="使用全角字符")
        self.full_width.set_halign(Gtk.Align.START)
        self._add_row(typography, 1, "字符宽度", self.full_width)
        return page

    def _build_appearance_page(self):
        page, content = self._new_page()
        candidate = self._new_section("候选窗口")
        content.pack_start(candidate, False, False, 0)
        self.candidate_page_size = self._choice_combo(
            tuple((size, str(size)) for size in range(3, 10))
        )
        self._add_row(candidate, 0, "每页候选", self.candidate_page_size)
        return page

    def _build_fuzzy_page(self):
        page, content = self._new_page()
        frame = Gtk.Frame(label="受控模糊音")
        content.pack_start(frame, False, False, 0)
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        box.set_border_width(14)
        frame.add(box)
        self.fuzzy_enabled = Gtk.CheckButton(label="启用模糊音")
        self.fuzzy_enabled.connect("toggled", self._update_fuzzy_sensitivity)
        box.pack_start(self.fuzzy_enabled, False, False, 0)
        self.fuzzy_grid = Gtk.Grid(column_spacing=36, row_spacing=10)
        box.pack_start(self.fuzzy_grid, False, False, 0)
        self.fuzzy_checks = []
        for index, name in enumerate(FUZZY_RULES):
            check = Gtk.CheckButton(label=name)
            self.fuzzy_grid.attach(check, index % 2, index // 2, 1, 1)
            self.fuzzy_checks.append(check)
        return page

    def _build_shortcuts_page(self):
        page, content = self._new_page()
        paging = self._new_section("候选翻页")
        content.pack_start(paging, False, False, 0)
        self.page_keys = self._combo(PAGE_KEY_SCHEMES)
        self.page_keys.connect("changed", self._page_keys_changed)
        self._add_row(paging, 0, "按键方案", self.page_keys)
        self.page_previous = Gtk.Label(label="-")
        self.page_previous.set_xalign(0)
        self._add_row(paging, 1, "上一页", self.page_previous)
        self.page_next = Gtk.Label(label="=")
        self.page_next.set_xalign(0)
        self._add_row(paging, 2, "下一页", self.page_next)

        completion = self._new_section("一键补全")
        content.pack_start(completion, False, False, 0)
        self.completion_key = self._combo(COMPLETION_KEYS)
        self.completion_key.connect("changed", self._completion_key_changed)
        self._add_row(completion, 0, "快捷键", self.completion_key)
        hint = Gtk.Label(
            label="输入至少两个完整音节，并存在可继续补全的精确词库词时生效。Tab 用作一键补全时，不能同时选择 Tab/Shift+Tab 翻页。"
        )
        hint.set_xalign(0)
        hint.set_line_wrap(True)
        self._add_row(completion, 1, "说明", hint)

        shortcuts = self._new_section("功能快捷键")
        content.pack_start(shortcuts, False, False, 0)
        header = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        modifier_header = Gtk.Label(label="修饰键")
        modifier_header.set_xalign(0)
        key_header = Gtk.Label(label="按键")
        key_header.set_xalign(0)
        header.pack_start(modifier_header, True, True, 0)
        header.pack_start(key_header, True, True, 0)
        self._add_row(shortcuts, 0, "功能", header)
        for row, (prefix, caption) in enumerate(SHORTCUTS, start=1):
            editor = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
            modifier = self._choice_combo(MODIFIER_CHOICES)
            key = self._choice_combo(KEY_CHOICES)
            editor.pack_start(modifier, True, True, 0)
            editor.pack_start(key, True, True, 0)
            self.shortcut_widgets[prefix] = (modifier, key)
            self._add_row(shortcuts, row, caption, editor)
        shortcut_hint = Gtk.Label(
            label="快捷键不可重复。无修饰键时仅支持 Shift 或 F1-F24，以免占用正常输入。"
        )
        shortcut_hint.set_xalign(0)
        shortcut_hint.set_line_wrap(True)
        shortcut_hint.get_style_context().add_class("dim-label")
        content.pack_start(shortcut_hint, False, False, 0)
        return page

    def _build_advanced_page(self):
        page, content = self._new_page()
        diagnostics = self._new_section("诊断")
        content.pack_start(diagnostics, False, False, 0)
        self.debug_mode = Gtk.CheckButton(label="在候选注释中显示调试信息")
        self.debug_mode.set_halign(Gtk.Align.START)
        self._add_row(diagnostics, 0, "调试模式", self.debug_mode)

        data = self._new_section("用户数据")
        content.pack_start(data, False, False, 0)
        data_path = Gtk.Label(label=default_data_directory())
        data_path.set_xalign(0)
        data_path.set_ellipsize(Pango.EllipsizeMode.MIDDLE)
        data_path.set_selectable(True)
        self._add_row(data, 0, "数据目录", data_path)
        actions = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        open_button = Gtk.Button(label="打开数据目录")
        open_button.connect("clicked", self._open_data_directory)
        actions.pack_start(open_button, False, False, 0)
        self.clear_user_button = Gtk.Button(label="清空用户词库")
        self.clear_user_button.get_style_context().add_class("destructive-action")
        self.clear_user_button.connect("clicked", self._clear_user_dictionary)
        actions.pack_start(self.clear_user_button, False, False, 0)
        self._add_row(data, 1, "操作", actions)
        warning = Gtk.Label(
            label="清空操作会删除本地用户词和相关学习记录，且无法撤销。"
        )
        warning.set_xalign(0)
        warning.set_line_wrap(True)
        self._add_row(data, 2, "说明", warning)
        return page

    def _update_fuzzy_sensitivity(self, _widget=None):
        self.fuzzy_grid.set_sensitive(self.fuzzy_enabled.get_active())

    def _completion_key_changed(self, _widget=None):
        if self.completion_key.get_active() == 0 and self.page_keys.get_active() == 3:
            self.page_keys.set_active(0)

    def _page_keys_changed(self, _widget=None):
        if self.page_keys.get_active() == 3 and self.completion_key.get_active() == 0:
            self.completion_key.set_active(1)
        index = self.page_keys.get_active()
        if 0 <= index < len(PAGE_KEY_PREVIEWS):
            previous, next_key = PAGE_KEY_PREVIEWS[index]
            self.page_previous.set_text(previous)
            self.page_next.set_text(next_key)

    @staticmethod
    def _set_combo_value(combo, value):
        if not combo.set_active_id(str(value)):
            combo.set_active(0)

    @staticmethod
    def _combo_value(combo):
        active_id = combo.get_active_id()
        return int(active_id) if active_id is not None else -1

    def _show_state(self, state):
        self.loaded_state = dict(state)
        self.current_dictionary_variant = state["dictionary_variant"]
        if state["input_mode"] == 1:
            self._set_combo_value(self.input_mode, 2)
        else:
            self._set_combo_value(
                self.input_mode, self.current_dictionary_variant
            )
        self._set_combo_value(self.pinyin_scheme, state["pinyin_scheme"])
        self.fuzzy_enabled.set_active(bool(state["fuzzy_pinyin_enabled"]))
        for index, check in enumerate(self.fuzzy_checks):
            check.set_active(bool(state["fuzzy_pinyin_rules"] & (1 << index)))
        self.full_width.set_active(bool(state["full_width_mode"]))
        self._set_combo_value(
            self.punctuation,
            0 if state["punctuation_full_width"] else 1,
        )
        self._set_combo_value(
            self.candidate_page_size, state["candidate_page_size"]
        )
        self._set_combo_value(
            self.page_keys, state["candidate_page_key_scheme"]
        )
        self._set_combo_value(
            self.completion_key, state["one_key_completion_key"]
        )
        self.debug_mode.set_active(bool(state["debug_mode"]))
        for prefix, _caption in SHORTCUTS:
            modifier, key = self.shortcut_widgets[prefix]
            self._set_combo_value(
                modifier, state[f"shortcut_{prefix}_modifiers"]
            )
            self._set_combo_value(key, state[f"shortcut_{prefix}_key"])
        self._update_fuzzy_sensitivity()

    def _collect_state(self):
        mask = 0
        for index, check in enumerate(self.fuzzy_checks):
            if check.get_active():
                mask |= 1 << index
        # Preserve fields added by a newer service so this UI cannot reset
        # settings it does not yet understand.
        selected_input_mode = self._combo_value(self.input_mode)
        if selected_input_mode == 0:
            input_mode = 0
            dictionary_variant = 0
        elif selected_input_mode == 1:
            input_mode = 0
            dictionary_variant = 1
        else:
            input_mode = 1
            dictionary_variant = self.current_dictionary_variant
        changes = {
            "input_mode": input_mode,
            "dictionary_variant": dictionary_variant,
            "pinyin_scheme": self._combo_value(self.pinyin_scheme),
            "fuzzy_pinyin_enabled": int(self.fuzzy_enabled.get_active()),
            "fuzzy_pinyin_rules": mask,
            "full_width_mode": int(self.full_width.get_active()),
            "punctuation_full_width": int(
                self._combo_value(self.punctuation) == 0
            ),
            "candidate_page_key_scheme": self._combo_value(self.page_keys),
            "one_key_completion_key": self._combo_value(self.completion_key),
            "candidate_page_size": self._combo_value(
                self.candidate_page_size
            ),
            "debug_mode": int(self.debug_mode.get_active()),
        }
        for prefix, _caption in SHORTCUTS:
            modifier, key = self.shortcut_widgets[prefix]
            changes[f"shortcut_{prefix}_modifiers"] = self._combo_value(modifier)
            changes[f"shortcut_{prefix}_key"] = self._combo_value(key)
        return merge_visible_state(self.loaded_state, changes)

    def _set_busy(self, busy, message):
        self.notebook.set_sensitive(not busy)
        self.defaults_button.set_sensitive(not busy)
        self.apply_button.set_sensitive(not busy)
        self.ok_button.set_sensitive(not busy)
        self.cancel_button.set_sensitive(not busy)
        self.clear_user_button.set_sensitive(not busy)
        self.status.set_text(message)

    def _run_operation(self, operation, pending_message,
                       success_message, failure_prefix,
                       close_on_success=False):
        self.operation_serial += 1
        serial = self.operation_serial
        self._set_busy(True, pending_message)
        worker = threading.Thread(
            target=self._operation_worker,
            args=(serial, operation, success_message, failure_prefix,
                  close_on_success),
            daemon=True,
        )
        worker.start()

    def _operation_worker(self, serial, operation,
                          success_message, failure_prefix,
                          close_on_success):
        try:
            state = operation()
            error = None
        except ControlError as exception:
            state = None
            error = str(exception)
        except Exception as exception:  # Keep GTK alive on IPC bugs.
            state = None
            error = str(exception)
        GLib.idle_add(
            self._finish_operation,
            serial,
            state,
            error,
            success_message,
            failure_prefix,
            close_on_success,
        )

    def _finish_operation(self, serial, state, error,
                          success_message, failure_prefix,
                          close_on_success):
        if self.closed or serial != self.operation_serial:
            return GLib.SOURCE_REMOVE
        self._set_busy(False, "")
        if error is None:
            self._show_state(state)
            if close_on_success:
                self.close()
            else:
                self.status.set_text(success_message)
        else:
            self.status.set_text(f"{failure_prefix}：{error}")
        return GLib.SOURCE_REMOVE

    def _load(self):
        self._run_operation(
            lambda: get_state(self.control_path),
            "正在读取当前设置…",
            "",
            "读取失败",
        )
        return GLib.SOURCE_REMOVE

    def _apply(self, _button):
        self._apply_changes(False)

    def _ok(self, _button):
        self._apply_changes(True)

    def _apply_changes(self, close_on_success):
        try:
            state = self._collect_state()
        except ControlError as error:
            self.status.set_text(f"应用失败：{error}")
            return
        self._run_operation(
            lambda: set_state(self.control_path, state),
            "正在应用设置…",
            "设置已应用",
            "应用失败",
            close_on_success,
        )

    def _restore_defaults(self, _button):
        page_index = self.notebook.get_current_page()
        if not 0 <= page_index < len(PAGE_DEFAULT_KEYS):
            return
        keys = PAGE_DEFAULT_KEYS[page_index]
        if not keys:
            self.status.set_text("当前页没有可恢复的跨平台设置")
            return
        tab = self.notebook.get_nth_page(page_index)
        caption = self.notebook.get_tab_label_text(tab)
        dialog = Gtk.MessageDialog(
            transient_for=self,
            modal=True,
            message_type=Gtk.MessageType.QUESTION,
            buttons=Gtk.ButtonsType.NONE,
            text=f"要恢复“{caption}”页的默认设置吗？",
        )
        dialog.add_button("取消", Gtk.ResponseType.CANCEL)
        dialog.add_button("恢复默认", Gtk.ResponseType.ACCEPT)
        response = dialog.run()
        dialog.destroy()
        if response != Gtk.ResponseType.ACCEPT:
            return
        try:
            state = self._collect_state()
        except ControlError as error:
            self.status.set_text(f"恢复默认失败：{error}")
            return
        for key in keys:
            state[key] = DEFAULT_STATE[key]
        self._show_state(validate_state(state))
        self.status.set_text(
            f"已载入“{caption}”页默认值，点击“应用”后生效"
        )

    def _cancel(self, _button):
        self.close()

    def _open_data_directory(self, _button):
        path = default_data_directory()
        try:
            os.makedirs(path, exist_ok=True)
            Gio.AppInfo.launch_default_for_uri(
                Gio.File.new_for_path(path).get_uri(), None
            )
            self.status.set_text("已打开数据目录")
        except (OSError, GLib.Error) as error:
            self.status.set_text(f"打开数据目录失败：{error}")

    def _clear_user_dictionary(self, _button):
        dialog = Gtk.MessageDialog(
            transient_for=self,
            modal=True,
            message_type=Gtk.MessageType.WARNING,
            buttons=Gtk.ButtonsType.NONE,
            text="确定要清空用户词库吗？",
        )
        dialog.format_secondary_text(
            "此操作将删除此前记住的本地用户词和相关学习记录，且无法撤销。"
        )
        dialog.add_button("取消", Gtk.ResponseType.CANCEL)
        dialog.add_button("清空", Gtk.ResponseType.ACCEPT)
        response = dialog.run()
        dialog.destroy()
        if response != Gtk.ResponseType.ACCEPT:
            return
        self._run_operation(
            lambda: clear_user_dictionary(self.control_path),
            "正在清空用户词库…",
            "用户词库已清空",
            "清空失败",
        )

    def _on_destroy(self, _widget):
        self.closed = True
        self.operation_serial += 1


class SettingsApplication(Gtk.Application):
    def __init__(self, control_path, engine_path):
        super().__init__(application_id="org.cassotis.ime.Settings",
                         flags=Gio.ApplicationFlags.FLAGS_NONE)
        self.control_path = control_path
        self.engine_path = engine_path

    def do_activate(self):
        window = self.props.active_window
        if window is None:
            window = SettingsWindow(self, self.control_path, self.engine_path)
        window.show_all()
        window.present()


def main():
    parser = argparse.ArgumentParser(description="Cassotis IME settings")
    parser.add_argument("--control", default=default_control_path())
    parser.add_argument("--engine", default=default_engine_path())
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--check-ui", action="store_true")
    options = parser.parse_args()
    if options.check_ui:
        version = read_engine_version(options.engine)
        if not version:
            raise ControlError("无法从 cassotis-engine 读取版本号")
        state = dict(DEFAULT_STATE)
        state["future_setting"] = 37
        state["candidate_page_size"] = 5
        state["debug_mode"] = 1
        merged = merge_visible_state(state, {"pinyin_scheme": 2})
        if merged["future_setting"] != 37 or \
                merged["candidate_page_size"] != 5 or \
                merged["debug_mode"] != 1:
            raise ControlError("应用设置时重置了未修改状态")
        modifier_values = {value for value, _caption in MODIFIER_CHOICES}
        key_values = {value for value, _caption in KEY_CHOICES}
        if 7 not in modifier_values or \
                not {0x6A, 0x6B, 0x6D, 0x6E, 0x6F}.issubset(key_values):
            raise ControlError("快捷键选项没有与 Windows 版完整对齐")
        numpad_state = dict(DEFAULT_STATE)
        numpad_state["shortcut_settings_key"] = 0x6B
        numpad_state["shortcut_settings_modifiers"] = 7
        validate_state(numpad_state)
        print(f"settings_ui=ok version={version}")
        return 0
    if options.check:
        get_state(options.control)
        print("settings_state=ok")
        return 0
    application = SettingsApplication(options.control, options.engine)
    return application.run(sys.argv[:1])


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except ControlError as error:
        print(f"cassotis-settings: {error}", file=sys.stderr)
        raise SystemExit(1)
