#!/usr/bin/env bash
set -euo pipefail
[[ ${GITHUB_REPOSITORY:-} == TuvalSystems/appmovil ]]
[[ ${GITHUB_REF:-} == refs/heads/develop ]]
[[ ${GITHUB_SHA:-} =~ ^[0-9a-f]{40}$ ]]
[[ ${GITHUB_RUN_ID:-} =~ ^[0-9]+$ ]]
[[ ${QA_VERSION:-} =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
# Segundos desde 2020: creciente, independiente del contador del workflow y < límite Android.
build_number=$(( $(date -u +%s) - 1577836800 ))
[[ $build_number -gt 2017 && $build_number -lt 2100000000 ]]
# La firma de distribución se aplica exclusivamente en srv-web02.
flutter build apk --release --flavor qa --target-platform android-arm64 --dart-define=APP_ENV=qa --build-number="$build_number" --build-name="$QA_VERSION"
mkdir -p dist/qa
python3 scripts/release_notes.py > dist/qa/release-notes.txt
cp build/app/outputs/flutter-apk/app-qa-release.apk dist/qa/app-qa-release.apk
build_tools=$(find "${ANDROID_HOME:?Falta ANDROID_HOME}/build-tools" -mindepth 1 -maxdepth 1 -type d | sort -V | tail -n 1)
"$build_tools/aapt" dump badging dist/qa/app-qa-release.apk > dist/qa/badging.txt
python3 - "$build_number" <<'PY'
import hashlib, json, os, pathlib, re, sys, zipfile
root = pathlib.Path('dist/qa')
match = re.search(r"^package: name='([^']+)' versionCode='(\d+)' versionName='([^']+)'", (root / 'badging.txt').read_text(), re.M)
if not match:
    raise SystemExit('No se puede leer la APK compilada.')
package, build, version = match.groups()
assert package == 'com.tuvalsa.tuvalapp.qa'
assert version == os.environ['QA_VERSION'] + '-qa', 'La versión de Android no coincide con QA'
assert int(build) == int(sys.argv[1]), 'El build de Android no coincide'
with zipfile.ZipFile(root / 'app-qa-release.apk') as apk:
    architectures = {name.split('/')[1] for name in apk.namelist() if name.startswith('lib/') and name.endswith('.so')}
assert architectures == {'arm64-v8a'}, f'Arquitecturas inesperadas: {architectures}'
metadata = {'package': package, 'buildNumber': int(build), 'versionName': version,
            'sha256': hashlib.sha256((root / 'app-qa-release.apk').read_bytes()).hexdigest(),
            'releaseNotes': (root / 'release-notes.txt').read_text().strip(),
            'commit': os.environ['GITHUB_SHA'],
            'runUrl': 'https://github.com/TuvalSystems/appmovil/actions/runs/' + os.environ['GITHUB_RUN_ID']}
(root / 'manifest.json').write_text(json.dumps(metadata, indent=2) + '\n')
(root / 'badging.txt').unlink()
print(json.dumps(metadata, indent=2))
PY
