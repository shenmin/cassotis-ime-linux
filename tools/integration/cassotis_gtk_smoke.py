#!/usr/bin/env python3

import argparse
import os
import sys

import gi


EXPECTED_TEXT = "\u4f60\u597d"
INPUT_TEXT = "nihao"


def parse_args():
    def positive_float(value):
        parsed = float(value)
        if parsed <= 0:
            raise argparse.ArgumentTypeError("must be greater than zero")
        return parsed

    parser = argparse.ArgumentParser(
        description="Exercise Cassotis through a real GTK IBus input context."
    )
    parser.add_argument(
        "--gtk",
        choices=("3", "4"),
        required=True,
        help="GTK major version to exercise",
    )
    parser.add_argument(
        "--focus-timeout",
        type=positive_float,
        default=30.0,
        help="seconds to wait for real desktop focus (default: 30)",
    )
    return parser.parse_args()


def main():
    args = parse_args()
    os.environ.setdefault("GTK_IM_MODULE", "ibus")
    gi.require_version("Atspi", "2.0")
    gi.require_version("Gtk", args.gtk + ".0")
    from gi.repository import Atspi, Gio, GLib, Gtk

    result = {"code": 1, "finished": False, "injected": False}
    application = Gtk.Application(
        application_id="com.cassotis.ime.GtkSmoke" + args.gtk,
        flags=Gio.ApplicationFlags.NON_UNIQUE,
    )

    def finish(window, entry):
        if result["finished"]:
            return GLib.SOURCE_REMOVE
        result["finished"] = True
        observed = entry.get_text()
        if observed == EXPECTED_TEXT:
            print("gtk_version=" + args.gtk)
            print("gtk_ibus_commit=" + observed)
            print("gtk_desktop_smoke=ok")
            result["code"] = 0
        else:
            print(
                "GTK "
                + args.gtk
                + " committed "
                + repr(observed)
                + " instead of "
                + repr(EXPECTED_TEXT),
                file=sys.stderr,
            )
        window.close()
        application.quit()
        return GLib.SOURCE_REMOVE

    def select_candidate(window, entry):
        if not Atspi.generate_keyboard_event(
            0x20, None, Atspi.KeySynthType.SYM
        ):
            print("Unable to inject GTK smoke selection.", file=sys.stderr)
            result["finished"] = True
            window.close()
            application.quit()
            return GLib.SOURCE_REMOVE
        GLib.timeout_add(1200, finish, window, entry)
        return GLib.SOURCE_REMOVE

    def inject(window, entry):
        entry.set_text("")
        result["injected"] = True
        if not Atspi.generate_keyboard_event(
            0, INPUT_TEXT, Atspi.KeySynthType.STRING
        ):
            print("Unable to inject GTK smoke pinyin.", file=sys.stderr)
            result["finished"] = True
            window.close()
            application.quit()
            return GLib.SOURCE_REMOVE
        GLib.timeout_add(300, select_candidate, window, entry)
        return GLib.SOURCE_REMOVE

    def activate(app):
        window = Gtk.ApplicationWindow(application=app)
        window.set_title("Cassotis GTK " + args.gtk + " smoke")
        window.set_default_size(480, 120)
        entry = Gtk.Entry()
        entry.set_placeholder_text("Focus this field; the test will type nihao")
        if args.gtk == "3":
            window.add(entry)
            window.show_all()
        else:
            window.set_child(entry)
            window.present()
        entry.grab_focus()
        print(
            "Focus the Cassotis GTK "
            + args.gtk
            + " smoke input field within "
            + str(args.focus_timeout)
            + " seconds.",
            file=sys.stderr,
        )

        deadline = GLib.get_monotonic_time() + int(args.focus_timeout * 1000000)

        def wait_for_focus():
            if result["finished"] or result["injected"]:
                return GLib.SOURCE_REMOVE
            if window.is_active() and entry.has_focus():
                return inject(window, entry)
            if GLib.get_monotonic_time() >= deadline:
                print(
                    "GTK smoke timed out waiting for desktop focus; "
                    "no input-method assertion was made.",
                    file=sys.stderr,
                )
                result["finished"] = True
                window.close()
                application.quit()
                return GLib.SOURCE_REMOVE
            return GLib.SOURCE_CONTINUE

        GLib.timeout_add(100, wait_for_focus)

    application.connect("activate", activate)
    application.run(None)
    return result["code"]


if __name__ == "__main__":
    raise SystemExit(main())
