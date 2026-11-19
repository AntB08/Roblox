#!/usr/bin/env python3
"""Regenerates test.project.json from default.project.json.

test.project.json = the production tree + ReplicatedStorage.DevPackages (Jest, from Wally)
+ ServerScriptService.Tests (tests/specs), with no globIgnorePaths so specs are included.

  python3 scripts/sync-test-project.py          # rewrite test.project.json
  python3 scripts/sync-test-project.py --check  # exit 1 if it is out of date (used by check.sh)

Never edit test.project.json by hand: edit default.project.json and re-run this.
"""
import copy
import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent


def build() -> str:
    default = json.loads((ROOT / "default.project.json").read_text())
    tree = copy.deepcopy(default["tree"])
    tree["ReplicatedStorage"]["DevPackages"] = {"$path": {"optional": "DevPackages"}}
    tree["ServerScriptService"]["Tests"] = {"$path": "tests/specs"}
    out = {
        "name": default["name"] + "-test",
        "emitLegacyScripts": default.get("emitLegacyScripts", True),
        "globIgnorePaths": [],
        "servePlaceIds": default.get("servePlaceIds", []),
        "tree": tree,
    }
    return json.dumps(out, indent=2) + "\n"


def main() -> int:
    target = ROOT / "test.project.json"
    expected = build()
    if "--check" in sys.argv:
        if not target.exists() or target.read_text() != expected:
            print("test.project.json is out of date: run python3 scripts/sync-test-project.py")
            return 1
        print("test.project.json is in sync")
        return 0
    target.write_text(expected)
    print("wrote test.project.json")
    return 0


if __name__ == "__main__":
    sys.exit(main())
