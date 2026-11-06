#!/usr/bin/env python3
"""Check Roblox API usage in Luau files (and ```lua blocks in Markdown) against the API dump.

Errors (precise): unknown/non-creatable class in Instance.new, unknown service in GetService,
unknown Enum.X.Y, unknown class names in IsA/FindFirstChildOfClass/...
Warnings (heuristic): calls to member names that exist in the engine only as deprecated members.

Usage: check_luau_api.py <file-or-folder> [...]
The API dump is looked up next to this script (../references/api/Mini-API-Dump.json inside the
skill) or in the knowledge-base repo (../reference/api/Mini-API-Dump.json).
"""
import json
import pathlib
import re
import sys

HERE = pathlib.Path(__file__).resolve().parent
CANDIDATES = [HERE.parent / "references/api/Mini-API-Dump.json", HERE.parent / "reference/api/Mini-API-Dump.json"]
dump_path = next((p for p in CANDIDATES if p.exists()), None)
if not dump_path:
    sys.exit("Mini-API-Dump.json not found")
dump = json.loads(dump_path.read_text())


def tags(x):
    return {t for t in x.get("Tags", []) if isinstance(t, str)}


classes = {c["Name"]: c for c in dump["Classes"]}
enums = {e["Name"]: {i["Name"] for i in e["Items"]} for e in dump["Enums"]}
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
# Old camelCase aliases (play -> Play, fire -> Fire) collide with user-defined module methods;
# only keep the ones that are a common real mistake on engine signals.
KEEP_ALIASES = {"connect", "disconnect"}
only_dead = {k: v for k, v in only_dead.items()
             if not (k[:1].islower() and k[:1].upper() + k[1:] in live) or k in KEEP_ALIASES}
GLOBAL_DEPRECATED = {"wait": "task.wait", "spawn": "task.spawn", "delay": "task.delay"}

pat_new = re.compile(r"Instance\.new\(\s*[\"'](\w+)[\"']")
pat_svc = re.compile(r"GetService\(\s*[\"'](\w+)[\"']")
pat_enum = re.compile(r"\bEnum\.(\w+)\.(\w+)")
pat_cls = re.compile(r"(?:IsA|FindFirstChildOfClass|FindFirstChildWhichIsA|FindFirstAncestorOfClass|FindFirstAncestorWhichIsA)\(\s*[\"'](\w+)[\"']")
pat_member = re.compile(r"(?<!table)(?<!string)(?<!buffer)(?<!math)(?<!task)(?<!coroutine)(?<!utf8)(?<!bit32)(?<!os)[:.]([A-Za-z_]\w*)\s*\(")
pat_sig = re.compile(r":(connect|disconnect|wait)\s*\(")  # old lowercase RBXScriptSignal/Connection methods
pat_global = re.compile(r"(?<![\w.:])(wait|spawn|delay)\s*\(")
block = re.compile(r"^```(lua|luau)[^\n]*\n(.*?)^```", re.M | re.S)


def chunks(path: pathlib.Path):
    text = path.read_text(encoding="utf-8", errors="ignore")
    if path.suffix == ".md":
        for m in block.finditer(text):
            yield text[: m.start()].count("\n") + 2, m.group(2)
    else:
        yield 1, text


errors = warnings = 0
files = []
for arg in sys.argv[1:] or ["."]:
    p = pathlib.Path(arg)
    files += sorted(p.rglob("*.lua*")) + sorted(p.rglob("*.md")) if p.is_dir() else [p]
for f in files:
    if "Packages" in f.parts or "node_modules" in f.parts or f.name.endswith(".d.luau"):
        continue
    for base, code in chunks(f):
        for off, line in enumerate(code.split("\n")):
            src = line.split("--", 1)[0]
            where = f"{f}:{base + off}"
            for n in pat_new.findall(src):
                if n not in classes:
                    print(f"{where}: ERROR Instance.new unknown class '{n}'"); errors += 1
                elif n not in creatable:
                    print(f"{where}: ERROR Instance.new non-creatable class '{n}'"); errors += 1
            for n in pat_svc.findall(src):
                if n not in services and n not in classes:
                    print(f"{where}: ERROR GetService unknown service '{n}'"); errors += 1
            for a, b in pat_enum.findall(src):
                if a not in enums:
                    print(f"{where}: ERROR unknown enum 'Enum.{a}'"); errors += 1
                elif b not in enums[a] and b not in ("GetEnumItems", "FromName", "FromValue"):
                    print(f"{where}: ERROR 'Enum.{a}' has no item '{b}'"); errors += 1
            for n in pat_cls.findall(src):
                if n not in classes:
                    print(f"{where}: ERROR unknown class name '{n}'"); errors += 1
            if re.match(r"\s*(local\s+)?function\b", src):
                continue
            for n in pat_sig.findall(src):
                if n != "wait" or re.search(r"(Event|Changed|Added|Removing|Signal|Touched|Ended|Activated)\s*:wait", src):
                    print(f"{where}: WARN ':{n}()' is deprecated on engine signals -> use :{n.capitalize()}()"); warnings += 1
            for n in pat_global.findall(src):
                print(f"{where}: WARN deprecated global '{n}()' -> use {GLOBAL_DEPRECATED[n]}()"); warnings += 1
            for n in pat_member.findall(src):
                if n in only_dead:
                    print(f"{where}: WARN deprecated API '{n}' ({'; '.join(sorted(only_dead[n]))[:160]})"); warnings += 1
sys.stdout.flush()
print(f"API check: {errors} errors, {warnings} deprecation warnings ({len(files)} files)")
sys.exit(1 if errors else 0)
