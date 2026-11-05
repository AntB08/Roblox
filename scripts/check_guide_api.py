#!/usr/bin/env python3
"""Check Roblox API usage in Luau code blocks against reference/api/Mini-API-Dump.json.

Verifies (precisely, no guessing):
  * Instance.new("X")        -> X is a real, creatable class
  * GetService("X")          -> X is a real service
  * Enum.A.B                 -> enum A exists and has item B
  * :IsA("X") / FindFirstChildOfClass("X") / FindFirstChildWhichIsA("X") -> X is a real class
Warns (heuristic):
  * :Name( / .Name where Name exists in the API ONLY as deprecated members (no live member
    of that name anywhere), e.g. :LoadCharacter( is fine to flag only if no class has a live one.

Usage: scripts/check_guide_api.py [files...]   (default: knowledge/*.md)
"""
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
dump = json.loads((ROOT / "reference/api/Mini-API-Dump.json").read_text())

classes = {c["Name"]: c for c in dump["Classes"]}
enums = {e["Name"]: {i["Name"] for i in e["Items"]} for e in dump["Enums"]}


def tags(x):
    return {t for t in x.get("Tags", []) if isinstance(t, str)}


services = {n for n, c in classes.items() if "Service" in tags(c)}
creatable = {n for n, c in classes.items() if "NotCreatable" not in tags(c)}
live, dead = set(), {}
for c in dump["Classes"]:
    for m in c["Members"]:
        if "Deprecated" in tags(m):
            pref = next((t.get("PreferredDescriptorName") for t in m.get("Tags", []) if isinstance(t, dict)), None)
            dead.setdefault(m["Name"], set()).add(f"{c['Name']}.{m['Name']}" + (f" -> {pref}" if pref else ""))
        else:
            live.add(m["Name"])
only_dead = {k: v for k, v in dead.items() if k not in live}

block = re.compile(r"^```(lua|luau)[^\n]*\n(.*?)^```", re.M | re.S)
pat_new = re.compile(r"Instance\.new\(\s*[\"'](\w+)[\"']")
pat_svc = re.compile(r"GetService\(\s*[\"'](\w+)[\"']")
pat_enum = re.compile(r"\bEnum\.(\w+)\.(\w+)")
pat_cls = re.compile(r"(?:IsA|FindFirstChildOfClass|FindFirstChildWhichIsA|FindFirstAncestorOfClass|FindFirstAncestorWhichIsA|GetPropertyChangedSignal_NO)\(\s*[\"'](\w+)[\"']")
pat_member = re.compile(r"(?<!table)(?<!string)(?<!buffer)(?<!math)(?<!task)(?<!coroutine)(?<!utf8)(?<!bit32)(?<!os)[:.]([A-Za-z_]\w*)\s*\(")

files = [pathlib.Path(f) for f in sys.argv[1:]] or sorted((ROOT / "knowledge").glob("*.md"))
errors = warnings = 0
for f in files:
    text = f.read_text(encoding="utf-8")
    for m in block.finditer(text):
        base = text[: m.start()].count("\n") + 2
        for off, line in enumerate(m.group(2).split("\n")):
            code = line.split("--", 1)[0]
            where = f"{f.relative_to(ROOT) if f.is_absolute() else f}:{base + off}"
            for n in pat_new.findall(code):
                if n not in classes:
                    print(f"{where}: ERROR Instance.new unknown class '{n}'"); errors += 1
                elif n not in creatable:
                    print(f"{where}: ERROR Instance.new non-creatable class '{n}'"); errors += 1
            for n in pat_svc.findall(code):
                if n not in services and n not in classes:
                    print(f"{where}: ERROR GetService unknown service '{n}'"); errors += 1
            for a, b in pat_enum.findall(code):
                if a not in enums:
                    print(f"{where}: ERROR unknown enum 'Enum.{a}'"); errors += 1
                elif b not in enums[a] and b not in ("GetEnumItems", "FromName", "FromValue"):
                    print(f"{where}: ERROR 'Enum.{a}' has no item '{b}'"); errors += 1
            for n in pat_cls.findall(code):
                if n not in classes:
                    print(f"{where}: ERROR unknown class name '{n}'"); errors += 1
            if re.match(r"\s*(local\s+)?function\b", code):
                continue  # a definition of the code's own function, not an engine call
            for n in pat_member.findall(code):
                if n in only_dead:
                    print(f"{where}: WARN deprecated API '{n}' ({'; '.join(sorted(only_dead[n]))[:160]})"); warnings += 1
print(f"API check: {errors} errors, {warnings} deprecation warnings (dump version {dump.get('Version')})")
sys.exit(1 if errors else 0)
