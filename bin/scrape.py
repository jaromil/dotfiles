#!/usr/bin/env python
from __future__ import annotations

import argparse
import sys
from pathlib import Path

import requests
from bs4 import BeautifulSoup
from readability import Document

USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) local-ai-web2txt/1.0"


def extract_text(html: str) -> str:
    article_html = Document(html).summary()
    text = BeautifulSoup(article_html, "html.parser").get_text("\n", strip=True)
    if text.strip():
        return text
    return BeautifulSoup(html, "html.parser").get_text("\n", strip=True)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Fetch a webpage and print extracted plain text.")
    parser.add_argument("url", nargs="?", help="URL to fetch")
    parser.add_argument("-o", "--output", type=Path, help="Optional output file path (written as UTF-8)")
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
        text = extract_text(response.text)
    except Exception as exc:
        print(f"Error: text extraction failed: {exc}", file=sys.stderr)
        return 2

    if not text.strip():
        print("Error: no text extracted", file=sys.stderr)
        return 3

    if args.output is not None:
        args.output.write_text(text, encoding="utf-8")
    else:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        print(text)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
