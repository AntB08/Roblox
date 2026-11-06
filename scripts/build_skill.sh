#!/usr/bin/env bash
# Assemble skills/roblox-game-dev/ from the knowledge base, so the skill works on its own
# (claude.ai upload) and as part of the Claude Code plugin. Re-run after editing knowledge/,
# templates/starter-game/ or the API files. SKILL.md itself is edited by hand.
set -euo pipefail
cd "$(dirname "$0")/.."
SK=skills/roblox-game-dev
rm -rf "$SK/references" "$SK/assets" "$SK/scripts"
mkdir -p "$SK/references/api" "$SK/assets" "$SK/scripts"
cp knowledge/*.md "$SK/references/"
cp reference/api/API-Dump.txt reference/api/Mini-API-Dump.json reference/api/LuauTypes.d.luau "$SK/references/api/"
cp reference/creator-docs-live/deprecated-api-inventory.md "$SK/references/api/"
cp -r templates/starter-game "$SK/assets/" && rm -rf "$SK/assets/starter-game/build"
cp scripts/check_luau_api.py "$SK/scripts/"
du -sh "$SK"
