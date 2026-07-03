#!/usr/bin/env python
from __future__ import annotations

import argparse
import re
import shutil
import subprocess
import sys
import tempfile
from dataclasses import dataclass, field
from pathlib import Path
from typing import Callable
from urllib.parse import urlparse

import requests
from bs4 import BeautifulSoup
from readability import Document

USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) local-ai-web2txt/1.0"
DomainFilter = Callable[[str, str, str], str]

# LLM extension guide:
# 1. Register a new domain in DOMAIN_FILTERS below using the site hostname.
# 2. Filters receive (url, html, extracted_text) and must return plain text.
# 3. Prefer the generic extracted_text unless the original HTML gives you a
#    clearly better structure, as with threaded comments or navigation noise.
# 4. Preserve useful content, remove site chrome, and return "" only when the
#    generic fallback should win.
# 5. Keep output stable and easy to parse: explicit labels beat clever layouts.
DOMAIN_FILTERS: dict[str, DomainFilter] = {}


@dataclass
class HackerNewsComment:
    """Structured Hacker News comment used to render a readable thread tree."""

    comment_id: str
    author: str
    text: str
    children: list["HackerNewsComment"] = field(default_factory=list)


def extract_text(html: str) -> str:
    """Extract readable plain text from an HTML document."""
    article_html = Document(html).summary()
    text = BeautifulSoup(article_html, "html.parser").get_text("\n", strip=True)
    if text.strip():
        return text
    return BeautifulSoup(html, "html.parser").get_text("\n", strip=True)


def resolve_domain_filter(url: str) -> DomainFilter | None:
    """Return the most specific registered filter for the URL hostname."""
    hostname = (urlparse(url).hostname or "").lower()
    matches = [
        (domain, domain_filter)
        for domain, domain_filter in DOMAIN_FILTERS.items()
        if hostname == domain or hostname.endswith(f".{domain}")
    ]
    if not matches:
        return None
    matches.sort(key=lambda item: len(item[0]), reverse=True)
    return matches[0][1]


def apply_domain_filter(url: str, html: str, extracted_text: str) -> str:
    """Run a domain-specific post-processor when one is registered."""
    domain_filter = resolve_domain_filter(url)
    if domain_filter is None:
        return extracted_text
    filtered_text = domain_filter(url, html, extracted_text)
    if filtered_text.strip():
        return filtered_text
    return extracted_text


def normalize_text_block(text: str) -> str:
    """Normalize multi-line text while preserving paragraph boundaries."""
    lines = [line.strip() for line in text.splitlines()]
    normalized: list[str] = []
    previous_blank = False
    for line in lines:
        is_blank = line == ""
        if is_blank and previous_blank:
            continue
        normalized.append(line)
        previous_blank = is_blank
    return "\n".join(normalized).strip()


def default_output_path(url: str) -> Path:
    """Build a stable filename from the URL using only safe ASCII characters."""
    parsed = urlparse(url)
    hostname = (parsed.netloc or parsed.hostname or "output").lower()
    path = parsed.path or ""
    query = f"_{parsed.query}" if parsed.query else ""
    fragment = f"_{parsed.fragment}" if parsed.fragment else ""
    raw_name = f"{hostname}{path}{query}{fragment}"
    safe_name = re.sub(r"[^a-z0-9]+", "_", raw_name.lower()).strip("_")
    if not safe_name:
        safe_name = "output"
    return Path(f"{safe_name}.txt")


def is_pdf_response(url: str, response: requests.Response) -> bool:
    """Detect whether the fetched resource should be treated as a PDF."""
    content_type = response.headers.get("Content-Type", "").lower()
    if "application/pdf" in content_type:
        return True

    content_disposition = response.headers.get("Content-Disposition", "").lower()
    if ".pdf" in content_disposition:
        return True

    return urlparse(url).path.lower().endswith(".pdf")


def extract_pdf_text(pdf_bytes: bytes) -> str:
    """Convert PDF bytes to plain text with pdftotext via a temp file."""
    if shutil.which("pdftotext") is None:
        raise RuntimeError("pdftotext command not found")

    with tempfile.TemporaryDirectory(prefix="scrape-pdf-") as temp_dir:
        pdf_path = Path(temp_dir) / "input.pdf"
        text_path = Path(temp_dir) / "output.txt"
        pdf_path.write_bytes(pdf_bytes)
        try:
            subprocess.run(
                ["pdftotext", str(pdf_path), str(text_path)],
                check=True,
                capture_output=True,
                text=True,
            )
        except subprocess.CalledProcessError as exc:
            stderr = exc.stderr.strip() if exc.stderr else "unknown pdftotext error"
            raise RuntimeError(f"pdftotext failed: {stderr}") from exc
        return text_path.read_text(encoding="utf-8")


def parse_hacker_news_comments(html: str) -> tuple[str, list[HackerNewsComment]]:
    """Parse Hacker News comments and reconstruct the reply tree from indent depth."""
    soup = BeautifulSoup(html, "html.parser")
    title_node = soup.select_one(".fatitem .titleline a") or soup.select_one("title")
    title = title_node.get_text(" ", strip=True) if title_node else ""
    roots: list[HackerNewsComment] = []
    stack: list[tuple[int, HackerNewsComment]] = []

    for row in soup.select("tr.athing.comtr"):
        body_node = row.select_one(".commtext")
        if body_node is None:
            continue
        text = normalize_text_block(body_node.get_text("\n\n", strip=True))
        if not text:
            continue

        author_node = row.select_one(".hnuser")
        author = author_node.get_text(" ", strip=True) if author_node else "[deleted]"
        indent_cell = row.select_one("td.ind")
        depth = 0
        if indent_cell is not None:
            indent_value = indent_cell.get("indent")
            if indent_value and indent_value.isdigit():
                depth = int(indent_value)
            else:
                spacer = indent_cell.select_one("img")
                width = spacer.get("width", "0") if spacer is not None else "0"
                if str(width).isdigit():
                    depth = int(width) // 40

        comment = HackerNewsComment(
            comment_id=row.get("id", ""),
            author=author,
            text=text,
        )

        while stack and stack[-1][0] >= depth:
            stack.pop()
        if stack:
            stack[-1][1].children.append(comment)
        else:
            roots.append(comment)
        stack.append((depth, comment))

    return title, roots


def render_hacker_news_comment(comment: HackerNewsComment, indent: int = 0) -> list[str]:
    """Render one Hacker News comment subtree as plain text."""
    prefix = " " * indent
    lines = [
        f"{prefix}- author: {comment.author}",
        f"{prefix}  text: |",
    ]
    for line in comment.text.splitlines():
        lines.append(f"{prefix}    {line}")
    if comment.children:
        lines.append(f"{prefix}  replies:")
        for child in comment.children:
            lines.extend(render_hacker_news_comment(child, indent + 4))
    return lines


def filter_hacker_news(url: str, html: str, extracted_text: str) -> str:
    """Render Hacker News comment pages as a clean reply tree."""
    del url
    del extracted_text
    title, comments = parse_hacker_news_comments(html)
    if not comments:
        return ""
    lines: list[str] = []
    if title:
        lines.append(f"Title: {title}")
        lines.append("")
    lines.append("Comments:")
    for comment in comments:
        lines.extend(render_hacker_news_comment(comment))
    return "\n".join(lines)


DOMAIN_FILTERS["news.ycombinator.com"] = filter_hacker_news


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Fetch a webpage and save extracted plain text.")
    parser.add_argument("url", nargs="?", help="URL to fetch")
    parser.add_argument("-o", "--output", type=Path, help="Output file path (written as UTF-8)")
    parser.add_argument("--timeout", type=float, default=30.0, help="HTTP timeout in seconds (default: 30)")
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    if not args.url:
        print("Error: missing URL argument", file=sys.stderr)
        print("Usage: local-ai-web2txt.py <url>", file=sys.stderr)
        return 2
    try:
        response = requests.get(
            args.url,
            timeout=args.timeout,
            headers={"User-Agent": USER_AGENT},
        )
        response.raise_for_status()
    except requests.RequestException as exc:
        print(f"Error: fetch failed: {exc}", file=sys.stderr)
        return 1

    try:
        if is_pdf_response(args.url, response):
            text = extract_pdf_text(response.content)
        else:
            text = apply_domain_filter(args.url, response.text, extract_text(response.text))
    except Exception as exc:
        print(f"Error: text extraction failed: {exc}", file=sys.stderr)
        return 2

    if not text.strip():
        print("Error: no text extracted", file=sys.stderr)
        return 3

    output_path = args.output or default_output_path(args.url)
    output_path.write_text(text, encoding="utf-8")
    print(output_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
