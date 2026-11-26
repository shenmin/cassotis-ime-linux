{ pkgs, framework, cassotis }:

let
  session = pkgs.writeShellScript "cassotis-input-session" ''
    set -eu
    fcitx5 -D >fcitx.log 2>&1 &
    frameworkPid=$!
    trap 'kill "$frameworkPid" 2>/dev/null || true' EXIT
    yad --entry --title=CassotisInputProbe --text="Input" >committed.txt &
    editor=$!
    window=$(timeout 20 xdotool search --sync --onlyvisible --name '^CassotisInputProbe$' | head -1)
    xdotool windowfocus --sync "$window"
    for i in $(seq 100); do
      fcitx5-remote -s cassotis >/dev/null 2>&1 || true
      if [[ "$(fcitx5-remote -n 2>/dev/null)" == cassotis ]]; then break; fi
      sleep .1
    done
    [[ "$(fcitx5-remote -n)" == cassotis ]] || { cat fcitx.log; exit 1; }
    xdotool type --clearmodifiers --delay 100 nihao
    xdotool key 1 Return
    wait "$editor"
    if [[ "$(cat committed.txt)" != 你好 ]]; then
      cat fcitx.log committed.txt >&2
      exit 1
    fi
    echo 'Fcitx 5 / GTK 3: nihao + 1 committed 你好'
    ${cassotis}/libexec/cassotis-ime/cassotis-settings --check-ui
    ${cassotis}/libexec/cassotis-ime/cassotis-settings --check
  '';
in
pkgs.runCommand "fcitx5-cassotis-input-check" {
  nativeBuildInputs = with pkgs; [ framework dbus xvfb-run xdotool yad ];
} ''
  export HOME="$TMPDIR/home" XDG_RUNTIME_DIR="$TMPDIR/runtime"
  export XDG_CONFIG_HOME="$HOME/.config"
  mkdir -p "$XDG_CONFIG_HOME/fcitx5"
  mkdir -m 700 "$XDG_RUNTIME_DIR"
  cat > "$XDG_CONFIG_HOME/fcitx5/profile" <<'PROFILE'
  [Groups/0]
  Name=Default
  Default Layout=us
  DefaultIM=cassotis

  [Groups/0/Items/0]
  Name=keyboard-us

  [Groups/0/Items/1]
  Name=cassotis

  [GroupOrder]
  0=Default
  PROFILE
  export GDK_BACKEND=x11 GTK_IM_MODULE=fcitx XMODIFIERS=@im=fcitx
  export GTK_IM_MODULE_FILE="$TMPDIR/immodules.cache"
  ${pkgs.gtk3.dev}/bin/gtk-query-immodules-3.0 \
    ${pkgs.fcitx5-gtk}/lib/gtk-3.0/*/immodules/im-fcitx5.so > "$GTK_IM_MODULE_FILE"
  timeout 90 xvfb-run -a dbus-run-session --config-file=${pkgs.dbus}/share/dbus-1/session.conf -- ${session}

  # A dictionary hit alone doesn't prove that the packaged model can run.
  ${pkgs.python3}/bin/python3 - "${cassotis}/libexec/cassotis-ime" <<'PY'
  import ctypes as c
  import math
  import pathlib
  import sys

  def utf16(text):
      return c.create_string_buffer((text + "\0").encode("utf-16-le"))

  runtime = pathlib.Path(sys.argv[1])
  lm = c.CDLL(str(runtime / "libcassotis_pinyin_transformer_ort.so"))
  ptr, integer = c.c_void_p, c.c_int
  lm.nc_lm_create.argtypes = [ptr, integer, ptr, integer]
  lm.nc_lm_create.restype = ptr
  lm.nc_lm_destroy.argtypes = [ptr]
  lm.nc_lm_destroy.restype = None
  lm.nc_lm_score.argtypes = [ptr, ptr, c.POINTER(ptr), integer, integer, integer,
                             c.POINTER(c.c_float), integer, ptr, integer]
  lm.nc_lm_score.restype = integer
  error = c.create_string_buffer(1024)
  handle = lm.nc_lm_create(utf16(str(runtime / "char_lm")), 1, error, 512)
  if not handle:
      sys.exit("model load: " + error.raw.decode("utf-16-le").split("\0")[0])
  try:
      word = utf16("你好")
      words = (ptr * 1)(c.addressof(word))
      score = c.c_float(float("nan"))
      count = lm.nc_lm_score(handle, None, words, 1, 1, 0, c.byref(score), 0, error, 512)
      if count != 1 or not math.isfinite(score.value):
          sys.exit("model score: " + error.raw.decode("utf-16-le").split("\0")[0])
      print("packaged character model: scored one candidate")
  finally:
      lm.nc_lm_destroy(handle)
  PY
  touch "$out"
''
