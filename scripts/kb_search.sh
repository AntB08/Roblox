#!/usr/bin/env bash
# Search the knowledge base. Usage:
#   scripts/kb_search.sh "UpdateAsync"            # guides + reference
#   scripts/kb_search.sh "ParticleEmitter" api    # only one area: knowledge|docs|api|luau|libs|examples|devforum (local mirror, run scripts/fetch_devforum.py first)
set -euo pipefail
cd "$(dirname "$0")/.."
q="$1"; area="${2:-all}"
case "$area" in
  knowledge) paths=(knowledge);;
  docs) paths=(reference/creator-docs);;
  api) paths=(reference/creator-docs/content/en-us/reference reference/api);;
  luau) paths=(reference/luau);;
  libs) paths=(reference/libraries);;
  examples) paths=(reference/example-games);;
  devforum) paths=(.sources/devforum);;
  *) paths=(knowledge reference);;
esac
if command -v rg >/dev/null; then rg -n -i --max-columns 200 -m 5 "$q" "${paths[@]}" | head -200
else grep -rn -i -m 5 "$q" "${paths[@]}" | cut -c1-200 | head -200; fi
