#!/usr/bin/env python3
"""Build a catalog of top YouTube videos per Roblox-dev topic from YouTube search result pages.

Collects only what a normal search page shows: title, channel, views, length, publish age,
description snippet, link. No video pages or captions are fetched.

Output: reference/video-library/catalog.json and reference/video-library/README.md
Usage:  python3 scripts/youtube_catalog.py            (uses TOPICS below)
"""
import json
import os
import re
import ssl
import time
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "reference" / "video-library"
ctx = ssl.create_default_context(cafile=os.environ.get("SSL_CERT_FILE") or None)

TOPICS = {
    "Roblox — game design & success": [
        "how to make a successful roblox game", "roblox game design tips retention", "roblox devlog how i made",
        "roblox game postmortem what went wrong", "roblox front page game breakdown", "roblox game ideas that work 2026",
        "roblox algorithm explained developers", "roblox game monetization tips", "roblox thumbnail and icon tips ctr",
        "roblox first time user experience onboarding",
    ],
    "Roblox — building & environment": [
        "roblox studio building tutorial", "roblox studio lighting tutorial", "roblox studio terrain tutorial",
        "roblox low poly map tutorial", "roblox studio realistic building", "roblox showcase build process",
        "roblox studio map design tips", "roblox studio interior design build", "roblox studio materials materialvariant",
        "roblox studio atmosphere skybox", "roblox obby design tutorial", "roblox lobby design",
    ],
    "Roblox — scripting": [
        "roblox studio scripting tutorial advanced", "roblox datastore profilestore tutorial", "roblox remote events security",
        "roblox oop luau tutorial", "roblox combat system tutorial", "roblox pet system egg hatching tutorial",
        "roblox tycoon tutorial scripting", "roblox simulator tutorial scripting", "roblox round system tutorial",
        "roblox pathfinding npc ai tutorial", "roblox anti exploit tutorial", "roblox rojo vscode setup",
        "roblox luau type checking strict", "roblox parallel luau actors", "roblox inventory system tutorial",
        "roblox gun system fastcast", "roblox vehicle chassis tutorial", "roblox placement system grid",
    ],
    "Roblox — UI": [
        "roblox ui design tutorial", "roblox studio gui scale mobile", "roblox ui animation tween",
        "roblox shop ui tutorial", "roblox ui design photoshop figma", "roblox simulator ui design",
    ],
    "Roblox — VFX, animation, audio": [
        "roblox vfx tutorial particles", "roblox studio beam trail tutorial", "roblox moon animator tutorial",
        "roblox animation editor tutorial", "roblox camera shake tutorial", "roblox sound design tutorial",
        "roblox studio new audio api", "roblox vfx anime ability tutorial", "roblox blender animation import",
    ],
    "Blender for Roblox": [
        "blender to roblox studio tutorial", "blender low poly modeling tutorial", "blender uv unwrapping tutorial beginner",
        "blender texture painting tutorial", "blender baking normal maps tutorial", "blender pbr texturing roblox surfaceappearance",
        "blender roblox rig animation", "blender roblox ugc accessory tutorial", "blender layered clothing roblox",
        "blender hard surface modeling beginner", "blender stylized tree tutorial", "blender low poly character",
        "blender geometry nodes beginner", "blender export fbx roblox scale", "blender roblox gfx render tutorial",
        "blender donut tutorial", "blender shortcuts beginners", "blender retopology tutorial",
    ],
    "Other 3D tools": [
        "blockbench roblox tutorial", "blockbench low poly modeling", "substance painter beginner tutorial",
        "substance painter roblox", "magicavoxel tutorial", "zbrush beginner tutorial", "maya modeling roblox",
    ],
    "2D art, icons, thumbnails": [
        "roblox game icon tutorial photoshop", "roblox thumbnail tutorial", "photopea roblox gfx tutorial",
        "krita digital painting beginner", "gimp beginner tutorial", "aseprite pixel art tutorial",
        "figma ui design tutorial beginner", "game ui icon design tutorial", "inkscape icon design tutorial",
        "photoshop game ui design",
    ],
    "Audio & music tools": [
        "audacity sound effects tutorial", "lmms beginner tutorial", "bandlab beginner tutorial",
        "how to make game music loop seamless", "fl studio game music tutorial", "game sound design tutorial foley",
        "jsfxr sfxr game sounds", "reaper beginner tutorial game audio",
    ],
    "Game design (general)": [
        "game design juice it or lose it", "the art of screenshake", "game feel tutorial", "level design tutorial gdc",
        "game economy design", "game progression design", "how to find the fun prototyping", "gmtk game design",
    ],
}


def search(q: str):
    url = "https://www.youtube.com/results?search_query=" + urllib.parse.quote(q)
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0", "Accept-Language": "en-US,en"})
    h = urllib.request.urlopen(req, context=ctx, timeout=30).read().decode("utf-8", "ignore")
    m = re.search(r"var ytInitialData = (\{.*?\});</script>", h)
    if not m:
        return []
    data = json.loads(m.group(1))
    out = []

    def text(x):
        if not x:
            return ""
        return x.get("simpleText") or "".join(r.get("text", "") for r in x.get("runs", []))

    def walk(o):
        if isinstance(o, dict):
            v = o.get("videoRenderer")
            if v:
                snip = ""
                for s in v.get("detailedMetadataSnippets", []):
                    snip += text(s.get("snippetText"))
                out.append({
                    "id": v["videoId"],
                    "url": f"https://www.youtube.com/watch?v={v['videoId']}",
                    "title": text(v.get("title")),
                    "channel": text(v.get("ownerText")),
                    "views": text(v.get("viewCountText")),
                    "length": text(v.get("lengthText")),
                    "published": text(v.get("publishedTimeText")),
                    "snippet": snip or text(v.get("descriptionSnippet")),
                })
            for x in o.values():
                walk(x)
        elif isinstance(o, list):
            for x in o:
                walk(x)

    walk(data)
    return out[:12]


def views_num(s: str) -> int:
    d = re.sub(r"[^0-9]", "", s or "")
    return int(d) if d else 0


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    catalog = {}
    for section, queries in TOPICS.items():
        catalog[section] = {}
        for q in queries:
            try:
                catalog[section][q] = search(q)
            except Exception as e:
                print("failed", q, e)
                catalog[section][q] = []
            print(f"{section} | {q}: {len(catalog[section][q])}", flush=True)
            time.sleep(1.5)
    (OUT / "catalog.json").write_text(json.dumps(catalog, indent=1, ensure_ascii=False), encoding="utf-8")
    lines = ["# Video library (YouTube search catalog)", "",
             "Top YouTube results per topic, collected from public search pages. Metadata only — these are",
             "pointers, not endorsements; view counts are popularity, not quality. Summaries of the best ones",
             "are in `knowledge/17-*` and `knowledge/18-*`. Transcripts: run `scripts/fetch_youtube_transcripts.py`",
             "on a normal home connection.", ""]
    for section, qs in catalog.items():
        lines += [f"## {section}", ""]
        for q, vids in qs.items():
            lines += [f"### {q}", ""]
            for v in sorted(vids, key=lambda v: -views_num(v["views"])):
                lines.append(f"- [{v['title']}]({v['url']}) — {v['channel']} · {v['views']} · {v['length']} · {v['published']}")
                if v["snippet"]:
                    lines.append(f"  - {v['snippet'][:220]}")
            lines.append("")
    (OUT / "README.md").write_text("\n".join(lines), encoding="utf-8")


if __name__ == "__main__":
    main()
