#!/usr/bin/env bash
set -euo pipefail
project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_config="$(mktemp -d)"
trap 'rm -rf "$test_config"' EXIT
python3 - "$project_dir" "$test_config" <<'PY'
import json,pathlib,sys
project=pathlib.Path(sys.argv[1])
config={'configVersion':2,'packages':[{'name':'circuito_descobertas','rootUri':(project/'mobile').as_uri()+'/', 'packageUri':'lib/','languageVersion':'3.9'}]}
(pathlib.Path(sys.argv[2])/'package_config.json').write_text(json.dumps(config))
PY
"${DART_BIN:-dart}" --packages="$test_config/package_config.json" "$project_dir/mobile/tool/test_core.dart"
