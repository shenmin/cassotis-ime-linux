{ lib, fetchurl, gnutar, gzip, version }:

let
  # Both portable builds ship the same databases. Use just one archive and
  # accept only the two files documented for this release.
  release = "2.10.0";
  bundle = "cassotis-ime-linux-${release}-x86_64";
in
assert lib.assertMsg (version == release)
  "Update packaging/nix/dictionaries.nix for the new Cassotis release";
fetchurl {
  name = "cassotis-dictionaries-${release}";
  url = "https://github.com/shenmin/cassotis-ime-linux/releases/download/v${release}/${bundle}.tar.gz";
  downloadToTemp = true;
  recursiveHash = true;
  # nix hash path on a directory containing just the two regular database files.
  hash = "sha256-eQyi1Y0VfHrBBvnvvu8aj9a2oIwq6/Sy4KSQoT+KwgI=";
  postFetch = ''
    mkdir -p "$out"
    cd "$out"
    ${gnutar}/bin/tar --use-compress-program=${gzip}/bin/gzip -xf "$downloadedFile" --strip-components=5 \
      ${bundle}/root/usr/share/cassotis-ime/dict_{sc,tc}.db
    sha256sum --check <<'SUMS'
    fe5391db08b2c4e98daa5e7f87088fe2e7965f24a7cf3ef3ccb8349c2495bf21  dict_sc.db
    0ead7dd4525126c0a575424ce234ba215320c04d057f8d9aaf19843557344ff2  dict_tc.db
    SUMS
  '';
}
