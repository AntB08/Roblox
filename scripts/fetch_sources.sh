#!/usr/bin/env bash
# Downloads the full upstream repositories behind reference/ (and extra,
# unlicensed-for-redistribution examples) into .sources/ for local study.
# .sources/ is gitignored. Re-run to update. Requires git.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .sources
REPOS=(
  # Official
  Roblox/creator-docs luau-lang/site luau-lang/rfcs luau-lang/luau
  Roblox/jest-roblox Roblox/testez
  # Engine API dumps + Roblox's own PlayerModule/CoreScripts (large: ~1.4 GB)
  MaximumADHD/Roblox-Client-Tracker
  # Tooling
  rojo-rbx/rojo rojo-rbx/rokit UpliftGames/wally Kampfkarren/selene
  JohnnyMorganz/StyLua JohnnyMorganz/luau-lsp lune-org/lune
  # Libraries
  Sleitnick/RbxUtil Sleitnick/Knit evaera/roblox-lua-promise dphfox/Fusion
  MadStudioRoblox/ProfileStore Ukendio/jecs 1Axen/blink centau/vide
  jsdotlua/react-lua Quenty/NevermoreEngine
  # Community example games (study only; check each repo's license before reuse)
  frrazer/roblox-game-boilerplate thegamerbay/simple-roblox-game
  AntonyPerez0/anomaly-grove Dekkonot/crossroads-rojo yoelthewhale/brickblast-roblox
  geartt01/astral-hatchery geartt01/bonk-blocks
  # Tool docs (local study only; no license for redistribution)
  JannisX11/blockbench.net audacity/audacity-support
)
mapfile -t -O "${#REPOS[@]}" REPOS < <(grep -v "^#" scripts/extra_repos.txt 2>/dev/null || true)
for r in "${REPOS[@]}"; do
  d=".sources/${r//\//_}"
  if [ -d "$d/.git" ]; then git -C "$d" pull -q --depth 1 || echo "update failed: $r"
  else git clone -q --depth 1 "https://github.com/$r" "$d" || echo "clone failed: $r"; fi
done
[ -d .sources/blender-manual/.git ] || git clone -q --depth 1 https://projects.blender.org/blender/blender-manual.git .sources/blender-manual || echo "clone failed: blender-manual"
du -sh .sources
