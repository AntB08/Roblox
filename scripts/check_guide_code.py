#!/usr/bin/env python3
"""Syntax-check every ```lua / ```luau code block in knowledge/*.md with luau-compile.
Usage: scripts/check_guide_code.py [path/to/luau-compile] [files...]"""
import pathlib, re, subprocess, sys, tempfile
compiler = sys.argv[1] if len(sys.argv) > 1 else "luau-compile"
files = [pathlib.Path(f) for f in sys.argv[2:]] or sorted(pathlib.Path("knowledge").glob("*.md"))
block = re.compile(r"^```(lua|luau)[^\n]*\n(.*?)^```", re.M | re.S)
total = bad = 0
for f in files:
    text = f.read_text(encoding="utf-8")
    for m in block.finditer(text):
        total += 1
        line = text[: m.start()].count("\n") + 1
        with tempfile.NamedTemporaryFile("w", suffix=".luau", delete=False) as t:
            t.write(m.group(2)); name = t.name
        r = subprocess.run([compiler, "--null", name], capture_output=True, text=True)
        if r.returncode != 0:
            bad += 1
            msg = (r.stderr or r.stdout).strip().replace(name, "")
            print(f"{f}:{line}: {msg[:300]}")
print(f"{total} blocks checked, {bad} with syntax errors")
sys.exit(1 if bad else 0)
