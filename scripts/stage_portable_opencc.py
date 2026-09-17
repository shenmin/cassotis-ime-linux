#!/usr/bin/env python3

"""Bundle the build host's OpenCC runtime and attribution for user installs."""

import ctypes
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys


def checksum(path):
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(block)
    return digest.hexdigest()


def loaded_library(prefix):
    paths = set()
    for line in Path('/proc/self/maps').read_text().splitlines():
        parts = line.split(maxsplit=5)
        if len(parts) == 6 and Path(parts[5]).name.startswith(prefix):
            paths.add(Path(parts[5]).resolve(strict=True))
    if len(paths) != 1:
        raise RuntimeError(f'Expected one loaded {prefix} library, got {paths}')
    return paths.pop()


def package_of(path):
    output = subprocess.check_output(
        ['dpkg-query', '-S', str(path)], text=True).strip().splitlines()
    if len(output) != 1 or ': ' not in output[0]:
        raise RuntimeError(f'Cannot determine package provenance: {path}')
    package = output[0].split(': ', 1)[0]
    if not re.fullmatch(r'[a-z0-9+.-]+(?::[a-z0-9]+)?', package):
        raise RuntimeError(f'Unexpected package name: {package}')
    version = subprocess.check_output(
        ['dpkg-query', '-W', '-f=${Version}', package], text=True)
    return package, version


def stage(root):
    root = root.resolve(strict=True)
    runtime = root / 'usr/libexec/cassotis-ime'
    if root == Path('/') or not (runtime / 'cassotis-engine').is_file():
        raise RuntimeError('Expected an isolated, staged portable release root')
    destination = runtime / 'opencc'
    if destination.exists():
        raise RuntimeError(f'Refusing to replace existing runtime: {destination}')

    library = None
    for name in ('libopencc.so.1.1', 'libopencc.so.2', 'libopencc.so.1'):
        try:
            library = ctypes.CDLL(name)
            break
        except OSError:
            pass
    if library is None:
        raise RuntimeError('Install the native OpenCC runtime and conversion data first')
    opencc = loaded_library('libopencc.so.')
    marisa = loaded_library('libmarisa.so.')
    source_data = Path('/usr/share/opencc')
    configs = [source_data / name for name in ('s2t.json', 't2s.json')]
    dictionaries = set()

    def collect(value):
        if isinstance(value, dict):
            if 'file' in value:
                name = value['file']
                if not isinstance(name, str) or Path(name).name != name:
                    raise RuntimeError(f'Unexpected OpenCC data path: {name!r}')
                dictionaries.add(source_data / name)
            for item in value.values():
                collect(item)
        elif isinstance(value, list):
            for item in value:
                collect(item)

    for config in configs:
        collect(json.loads(config.read_text(encoding='utf-8')))
    sources = {opencc: 'libopencc.so', marisa: 'libmarisa.so'}
    sources.update({p: p.name for p in configs + sorted(dictionaries)})
    provenance = {}
    for path in sources:
        package, version = package_of(path)
        provenance[package] = version
    notices = {}
    for package in provenance:
        name = package.split(':')[0]
        path = Path('/usr/share/doc') / name / 'copyright'
        if not path.is_file():
            raise RuntimeError(f'Missing third-party attribution: {path}')
        notices[path] = name + '-copyright'
    apache = Path('/usr/share/common-licenses/Apache-2.0')
    if not apache.is_file():
        raise RuntimeError('Missing complete Apache-2.0 license text')
    notices[apache] = 'Apache-2.0'
    destination.mkdir()
    for source, name in sources.items():
        shutil.copyfile(source, destination / name)
        (destination / name).chmod(0o755 if name.endswith('.so') else 0o644)
    docs = root / 'usr/share/doc/cassotis-ime/third-party/opencc'
    docs.mkdir(parents=True, exist_ok=True)
    for source, name in notices.items():
        shutil.copyfile(source, docs / name)
    (docs / 'bundle-provenance.json').write_text(json.dumps({
        'opencc': 'https://github.com/BYVoid/OpenCC',
        'marisa': 'https://github.com/s-yata/marisa-trie',
        'licenses': {'OpenCC': 'Apache-2.0', 'MARISA': 'BSD-2-Clause'},
        'modifications': 'Libraries and conversion data are copied without modification.',
        'packages': provenance,
        'files': {name: checksum(destination / name) for name in sources.values()},
    }, indent=2, sort_keys=True) + '\n', encoding='utf-8')

    data = root / 'usr/share/cassotis-ime'
    manifest = data / 'release-manifest.txt'
    sums = data / 'release-sha256.txt'
    files = sorted(p for p in root.rglob('*') if p.is_file() and p not in (manifest, sums))
    manifest.write_text(''.join(p.relative_to(root).as_posix() + '\n' for p in files), encoding='utf-8')
    sums.write_text(''.join(checksum(p) + '  ./' + p.relative_to(root).as_posix() + '\n'
                           for p in files), encoding='utf-8')
    print(f'Portable OpenCC: {len(sources)} files; packages={provenance}')


if __name__ == '__main__':
    if len(sys.argv) != 2:
        raise SystemExit('Usage: stage_portable_opencc.py STAGED_BUNDLE_ROOT')
    stage(Path(sys.argv[1]))
