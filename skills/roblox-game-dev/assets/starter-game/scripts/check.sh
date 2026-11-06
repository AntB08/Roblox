#!/usr/bin/env bash
# Quality gate. Must pass before every commit (CI runs it too).
#   scripts/check.sh            # full gate
#   SKIP_TOOLCHAIN=1 scripts/check.sh   # tools already installed / on PATH
set -euo pipefail
cd "$(dirname "$0")/.."

if [ -z "${SKIP_TOOLCHAIN:-}" ]; then
  rokit install --no-trust-check >/dev/null
fi
# Wally is only needed for Jest (dev) and for projects that switched off the vendored packages.
if [ -f wally.toml ] && command -v wally >/dev/null; then
  wally install >/dev/null
fi

echo "== json"
python3 - <<'PY'
import json, pathlib, sys
bad = 0
for p in list(pathlib.Path(".").glob("*.json")) + list(pathlib.Path("src").rglob("*.json")):
    try:
        json.loads(p.read_text())
    except Exception as e:
        print(f"invalid JSON: {p}: {e}"); bad += 1
sys.exit(1 if bad else 0)
PY
python3 scripts/sync-test-project.py --check

echo "== format";  stylua --check src tests lune
echo "== lint";    selene src tests lune

echo "== sourcemap"
rojo sourcemap default.project.json -o sourcemap.json --include-non-scripts
[ -d Packages ] && wally-package-types --sourcemap sourcemap.json Packages/ >/dev/null || true
[ -d ServerPackages ] && wally-package-types --sourcemap sourcemap.json ServerPackages/ >/dev/null || true

mkdir -p .luau-lsp
[ -f .luau-lsp/globalTypes.d.luau ] || curl -fsSL -o .luau-lsp/globalTypes.d.luau \
  https://luau-lsp.pages.dev/type-definitions/globalTypes.None.d.luau

echo "== typecheck"
luau-lsp analyze --platform=roblox --sourcemap=sourcemap.json \
  --definitions=@roblox=.luau-lsp/globalTypes.d.luau --base-luaurc=.luaurc --formatter=plain \
  --ignore="**/Packages/**" --ignore="**/ServerPackages/**" --ignore="**/DevPackages/**" \
  src

echo "== build"
mkdir -p build
rojo build default.project.json -o build/game.rbxl
rojo build test.project.json -o build/test.rbxl

echo "== place checks"
lune run lune/scan-place build/game.rbxl

echo "ALL CHECKS PASSED"
