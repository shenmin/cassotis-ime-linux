{
  lib, stdenv, callPackage, autoPatchelfHook, coreutils, fcitx5, fpc, glib,
  gobject-introspection, gtk3, ibus, opencc, pkg-config, python3, sqlite,
  wrapGAppsHook3,
}:

let
  root = ../..;
  version = lib.removeSuffix "\n" (builtins.readFile (root + "/VERSION"));
  dictionaries = callPackage ./dictionaries.nix { inherit version; };
  settingsPython = python3.withPackages (p: [ p.pygobject3 p.pycairo ]);
in
stdenv.mkDerivation {
  pname = "fcitx5-cassotis";
  inherit version;
  src = lib.fileset.toSource {
    inherit root;
    fileset = lib.fileset.unions (map (name: root + "/${name}") [
      "VERSION" "LICENSE" "NOTICE.md" "cassotis_ime_yanquan_mark.png"
      "docs/LEXICON_ATTRIBUTION.md" "docs/LCCC-LICENSE.txt"
      "adapters" "src" "third_party" "tools/control"
      "data/models/char_lm" "data/runtime-assets.sha256" "data/wubi86_table.txt"
      "scripts/build.sh" "scripts/common.sh" "scripts/validate_runtime_assets.sh"
      "scripts/char_lm_model_parts.py" "scripts/model_weights.py"
    ]);
  };

  nativeBuildInputs = [ autoPatchelfHook fpc gobject-introspection pkg-config python3 wrapGAppsHook3 ];
  buildInputs = [ fcitx5 glib gtk3 ibus stdenv.cc.cc.lib ];
  dontConfigure = true;
  dontWrapGApps = true;
  strictDeps = true;

  postPatch = ''
    patchShebangs scripts
    substituteInPlace src/host/nc_model_assets.pas \
      --replace-fail /usr/bin/sha256sum ${coreutils}/bin/sha256sum
    openccLib=(${lib.getLib opencc}/lib/libopencc.so.*)
    test -f "''${openccLib[0]}"
    openccPath="$(realpath "''${openccLib[0]}")"
    substituteInPlace src/common/nc_chinese_script.pas \
      --replace-fail "'libopencc.so.1.1'" "'$openccPath'"
  '';

  buildPhase = ''
    runHook preBuild
    CASSOTIS_FCITX_LIBEXECDIR="$out/libexec/cassotis-ime" bash scripts/build.sh
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    runtime="$out/libexec/cassotis-ime"
    data="$out/share/cassotis-ime"
    doc="$out/share/doc/cassotis-ime"
    mkdir -p "$runtime" "$data" "$out/share/fcitx5/addon" "$doc"
    install -m755 build/bin/{cassotis-engine,cassotis-control} "$runtime/"
    source scripts/common.sh
    cassotis_stage_neural_runtime build/bin "$runtime"
    ln -s ${lib.getLib sqlite}/lib/libsqlite3.so.0 "$runtime/libsqlite3.so.0"
    ln -s ${dictionaries}/dict_{sc,tc}.db "$data/"
    install -m644 data/wubi86_table.txt "$data/"

    install -Dm755 build/bin/libcassotis.so "$out/lib/fcitx5/libcassotis.so"
    sed -e "s|@VERSION@|$version|g" \
        -e "s|@FCITX_VERSION@|$(pkg-config --modversion Fcitx5Core)|g" \
        -e "s|@LIBRARY@|$out/lib/fcitx5/libcassotis|g" \
        adapters/fcitx5/cassotis-addon.conf.in > "$out/share/fcitx5/addon/cassotis.conf"
    install -Dm644 adapters/fcitx5/cassotis.conf "$out/share/fcitx5/inputmethod/cassotis.conf"
    install -Dm644 cassotis_ime_yanquan_mark.png "$out/share/icons/hicolor/512x512/apps/cassotis-ime.png"
    install -m755 adapters/ibus/cassotis_settings.py "$runtime/cassotis-settings"
    sed -i '1c#!${settingsPython}/bin/python3' "$runtime/cassotis-settings"
    install -m644 LICENSE NOTICE.md "$doc/"
    install -Dm644 -t "$doc/docs" docs/{LEXICON_ATTRIBUTION.md,LCCC-LICENSE.txt}
    for component in onnxruntime opencc wubi_haifeng; do
      install -Dm644 third_party/$component/LICENSE "$doc/third-party/$component/LICENSE"
    done
    install -m644 third_party/onnxruntime/ThirdPartyNotices.txt "$doc/third-party/onnxruntime/"
    runHook postInstall
  '';

  preFixup = ''
    wrapProgram "$out/libexec/cassotis-ime/cassotis-settings" "''${gappsWrapperArgs[@]}"
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    runtime="$out/libexec/cassotis-ime"
    test "$("$runtime/cassotis-engine" --version)" = "$version"
    test -s "$runtime/char_lm/char_lm.onnx"
    test -s "$out/share/cassotis-ime/dict_sc.db"
    test -s "$out/share/cassotis-ime/dict_tc.db"
    runHook postInstallCheck
  '';

  meta = {
    description = "Chinese Pinyin input method with a local character language model for Fcitx 5";
    homepage = "https://github.com/shenmin/cassotis-ime-linux";
    license = with lib.licenses; [ gpl3Only cc-by-sa-40 ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
}
