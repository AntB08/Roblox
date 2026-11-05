#!/usr/bin/env python3
"""Download high-value Roblox DevForum threads as Markdown for local, searchable study.

Output: .sources/devforum/<category>/<topic_id>-<slug>.md  (gitignored — forum posts belong to
their authors; keep this mirror local, don't republish it) and .sources/devforum/index.tsv.

Uses only the Python standard library and the public Discourse JSON API. Polite by default
(~1.5 requests/s, honours 429 Retry-After). Resumable: existing files are skipped.

Usage:
  python3 scripts/fetch_devforum.py                 # all configured categories
  python3 scripts/fetch_devforum.py tutorials resources   # only some
  python3 scripts/fetch_devforum.py --list          # show the plan
"""
from __future__ import annotations

import html
import json
import os
import re
import ssl
import sys
import time
import urllib.error
import urllib.request
from html.parser import HTMLParser
from pathlib import Path

BASE = "https://devforum.roblox.com"
UA = "roblox-kb-research/1.0 (personal study mirror)"
DELAY = float(os.environ.get("DEVFORUM_DELAY", "0.65"))
OUT = Path(__file__).resolve().parent.parent / ".sources" / "devforum"

# name: (category path, category id, listing, max topics, min reply likes to keep a reply)
PLAN = {
    "tutorials": ("resources/community-tutorials", 46, "top", 4000, 3),
    "resources": ("resources/community-resources", 74, "top", 4000, 5),
    "announcements": ("updates/announcements", 36, "latest", 3000, 25),
    "release-notes": ("updates/release-notes", 62, "latest", 600, 1000000),
    "game-design": ("help-and-feedback/game-design-support", 103, "top", 3000, 3),
    "art-design": ("help-and-feedback/art-design-support", 57, "top", 2000, 3),
    "building": ("help-and-feedback/building-support", 56, "top", 2000, 3),
    "creations-feedback": ("help-and-feedback/creations-feedback", 20, "top", 2500, 3),
    "scripting": ("help-and-feedback/scripting-support", 55, "top", 5000, 3),
    "code-review": ("help-and-feedback/code-review", 75, "top", 1200, 3),
    "engine-features": ("feature-requests/engine-features", 23, "top", 600, 20),
    "roblox-staff": ("resources/roblox-staff", 278, "latest", 200, 5),
}

ctx = ssl.create_default_context(cafile=os.environ.get("SSL_CERT_FILE") or None)


def get_json(url: str, tries: int = 6):
    for attempt in range(tries):
        req = urllib.request.Request(url, headers={"User-Agent": UA, "Accept": "application/json"})
        try:
            with urllib.request.urlopen(req, context=ctx, timeout=60) as r:
                data = json.load(r)
            time.sleep(DELAY)
            return data
        except urllib.error.HTTPError as e:
            if e.code == 429:
                wait = int(e.headers.get("Retry-After") or 20) + 2
                print(f"  429, waiting {wait}s", flush=True)
                time.sleep(wait)
                continue
            if e.code in (403, 404, 410):
                return None
            time.sleep(5 * (attempt + 1))
        except Exception as e:  # network hiccup
            print(f"  error {e!r}, retrying", flush=True)
            time.sleep(5 * (attempt + 1))
    return None


class HtmlToMd(HTMLParser):
    """Small, forgiving HTML→Markdown converter for Discourse 'cooked' posts."""

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.out: list[str] = []
        self.pre = 0
        self.href: list[str | None] = []
        self.skip = 0

    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        cls = a.get("class") or ""
        if self.skip or "lightbox-wrapper" in cls and tag == "div":
            pass
        if tag in ("script", "style") or (tag == "div" and "meta" == cls):
            self.skip += 1
        elif tag == "pre":
            self.pre += 1
            self.out.append("\n```\n")
        elif tag == "code" and not self.pre:
            self.out.append("`")
        elif tag in ("h1", "h2", "h3", "h4", "h5", "h6"):
            self.out.append("\n\n" + "#" * (int(tag[1]) + 1) + " ")
        elif tag in ("p", "div", "blockquote", "aside"):
            self.out.append("\n\n" + ("> " if tag == "blockquote" else ""))
        elif tag == "br":
            self.out.append("\n")
        elif tag == "li":
            self.out.append("\n- ")
        elif tag in ("strong", "b"):
            self.out.append("**")
        elif tag in ("em", "i"):
            self.out.append("*")
        elif tag == "a":
            self.href.append(a.get("href"))
            self.out.append("[")
        elif tag == "img":
            alt = a.get("alt") or "image"
            if "emoji" not in cls:
                self.out.append(f"[img: {alt}]")
        elif tag == "tr":
            self.out.append("\n| ")
        elif tag in ("td", "th"):
            pass

    def handle_endtag(self, tag):
        if tag in ("script", "style"):
            self.skip = max(0, self.skip - 1)
        elif tag == "pre":
            self.pre = max(0, self.pre - 1)
            self.out.append("\n```\n")
        elif tag == "code" and not self.pre:
            self.out.append("`")
        elif tag in ("strong", "b"):
            self.out.append("**")
        elif tag in ("em", "i"):
            self.out.append("*")
        elif tag == "a":
            href = self.href.pop() if self.href else None
            if href and href.startswith("/"):
                href = BASE + href
            self.out.append(f"]({href})" if href else "]")
        elif tag in ("td", "th"):
            self.out.append(" | ")

    def handle_data(self, data):
        if self.skip:
            return
        self.out.append(data if self.pre else re.sub(r"\s+", " ", data))

    def text(self) -> str:
        s = "".join(self.out)
        s = re.sub(r"\n{3,}", "\n\n", s)
        return s.strip()


def to_md(cooked: str) -> str:
    p = HtmlToMd()
    p.feed(cooked or "")
    return p.text()


def slugify(s: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", s.lower()).strip("-")[:70] or "topic"


def list_topics(path: str, cid: int, listing: str, limit: int):
    seen, page = [], 0
    while len(seen) < limit:
        if listing == "top":
            url = f"{BASE}/c/{path}/{cid}/l/top.json?period=all&per_page=50&page={page}"
        else:
            url = f"{BASE}/c/{path}/{cid}/l/latest.json?per_page=50&page={page}"
        d = get_json(url)
        if not d:
            break
        topics = d.get("topic_list", {}).get("topics", [])
        if not topics:
            break
        seen.extend(topics)
        page += 1
        if not d["topic_list"].get("more_topics_url"):
            break
    return seen[:limit]


def fetch_topic(t: dict, name: str, min_reply_likes: int, index):
    tid = t["id"]
    folder = OUT / name
    folder.mkdir(parents=True, exist_ok=True)
    fn = folder / f"{tid}-{slugify(t.get('slug') or t['title'])}.md"
    if fn.exists():
        return False
    d = get_json(f"{BASE}/t/{tid}.json")
    if not d:
        return False
    posts = d.get("post_stream", {}).get("posts", [])
    accepted = (d.get("accepted_answer") or {}).get("post_number")
    lines = [
        f"# {d.get('title', t['title'])}",
        "",
        f"- URL: {BASE}/t/{d.get('slug', 'x')}/{tid}",
        f"- Category: {name}",
        f"- Created: {d.get('created_at', '')[:10]}  Last activity: {(d.get('last_posted_at') or '')[:10]}",
        f"- Likes: {d.get('like_count', t.get('like_count', 0))}  Views: {d.get('views', 0)}  Replies: {d.get('posts_count', 1) - 1}",
        f"- Tags: {', '.join(x if isinstance(x, str) else x.get('name', '') for x in d.get('tags', []))}",
        "",
    ]
    for p in posts:
        n = p.get("post_number")
        likes = sum(a.get("count", 0) for a in p.get("actions_summary", []) if a.get("id") == 2)
        likes = max(likes, p.get("like_count", 0) or 0)
        if n != 1 and n != accepted and likes < min_reply_likes:
            continue
        label = "Original post" if n == 1 else ("Accepted answer" if n == accepted else f"Reply #{n}")
        staff = " (Roblox staff)" if p.get("staff") else ""
        lines.append(f"## {label} — {p.get('username', '?')}{staff}, {likes} likes, {p.get('created_at', '')[:10]}")
        lines.append("")
        lines.append(to_md(p.get("cooked", "")))
        lines.append("")
    fn.write_text(html.unescape("\n".join(lines)), encoding="utf-8")
    index.write(
        f"{name}\t{tid}\t{d.get('like_count', 0)}\t{d.get('views', 0)}\t{(d.get('created_at') or '')[:10]}\t"
        f"{d.get('title', '').replace(chr(9), ' ')}\t{BASE}/t/{tid}\n"
    )
    index.flush()
    return True


def main(argv):
    names = [a for a in argv if not a.startswith("--")] or list(PLAN)
    if "--list" in argv:
        for k, v in PLAN.items():
            print(k, v)
        return
    OUT.mkdir(parents=True, exist_ok=True)
    with open(OUT / "index.tsv", "a", encoding="utf-8") as index:
        for name in names:
            path, cid, listing, limit, min_likes = PLAN[name]
            print(f"== {name}: listing up to {limit}", flush=True)
            topics = list_topics(path, cid, listing, limit)
            print(f"   {len(topics)} topics listed", flush=True)
            new = 0
            for i, t in enumerate(topics, 1):
                if fetch_topic(t, name, min_likes, index):
                    new += 1
                if i % 100 == 0:
                    print(f"   {name}: {i}/{len(topics)} ({new} new)", flush=True)
            print(f"== {name}: done, {new} new", flush=True)


if __name__ == "__main__":
    main(sys.argv[1:])
