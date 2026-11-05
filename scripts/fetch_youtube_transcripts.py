#!/usr/bin/env python3
"""Download English transcripts for the videos in reference/video-library/catalog.json.

Run this on your own computer (a normal home connection). Cloud/datacenter connections get
YouTube's bot check, and this script does not try to get around it.

    pip install youtube-transcript-api
    python3 scripts/fetch_youtube_transcripts.py            # all catalog videos
    python3 scripts/fetch_youtube_transcripts.py --top 3    # top 3 per search topic by views

Output: .sources/youtube-transcripts/<video_id>.md (gitignored: transcripts belong to their
creators — keep them local). Then the bot can search them with:
    scripts/kb_search.sh "<term>" transcripts
and summarize the best ones into knowledge/17-*.md or 18-*.md with a link to each video.
Resumable; waits 2 s between videos.
"""
import json
import re
import sys
import time
from pathlib import Path

try:
    from youtube_transcript_api import YouTubeTranscriptApi
except ImportError:
    sys.exit("pip install youtube-transcript-api")

ROOT = Path(__file__).resolve().parent.parent
CATALOG = ROOT / "reference" / "video-library" / "catalog.json"
OUT = ROOT / ".sources" / "youtube-transcripts"


def views(s: str) -> int:
    d = re.sub(r"[^0-9]", "", s or "")
    return int(d) if d else 0


def main(argv):
    top = int(argv[argv.index("--top") + 1]) if "--top" in argv else None
    catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
    OUT.mkdir(parents=True, exist_ok=True)
    api = YouTubeTranscriptApi()
    seen = set()
    for section, queries in catalog.items():
        for q, vids in queries.items():
            vids = sorted(vids, key=lambda v: -views(v["views"]))
            for v in vids[:top] if top else vids:
                if v["id"] in seen:
                    continue
                seen.add(v["id"])
                fn = OUT / f"{v['id']}.md"
                if fn.exists():
                    continue
                try:
                    t = api.fetch(v["id"], languages=["en", "en-US", "en-GB"])
                except Exception as e:  # no captions, private, etc.
                    print(f"skip {v['id']}: {type(e).__name__}")
                    continue
                lines = [f"# {v['title']}", "", f"- URL: {v['url']}", f"- Channel: {v['channel']}",
                         f"- Views: {v['views']}  Length: {v['length']}  Published: {v['published']}",
                         f"- Topic: {section} / {q}", "", "## Transcript", ""]
                chunk, start = [], None
                for s in t:
                    start = s.start if start is None else start
                    chunk.append(s.text.replace("\n", " "))
                    if s.start - start >= 60:
                        lines.append(f"[{int(start // 60)}:{int(start % 60):02d}] " + " ".join(chunk))
                        chunk, start = [], None
                if chunk:
                    lines.append(f"[{int(start // 60)}:{int(start % 60):02d}] " + " ".join(chunk))
                fn.write_text("\n".join(lines), encoding="utf-8")
                print(f"saved {v['id']} {v['title'][:60]}")
                time.sleep(2)


if __name__ == "__main__":
    main(sys.argv[1:])
