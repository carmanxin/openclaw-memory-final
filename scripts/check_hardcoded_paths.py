#!/usr/bin/env python3
"""Fail fast on user-specific absolute paths committed into the repo.

Purpose:
- catch runtime-breaking hardcoded local paths before merge/push
- keep docs/examples portable across different users/machines

Allow generic paths like `~/.openclaw/workspace` or `$HOME/...`.
Block user-specific absolute paths such as `/home/alice/...`, `/Users/bob/...`,
`/root/...`, or `C:\\Users\\name\\...`.
"""

from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
SELF_PATH = Path(__file__).resolve().relative_to(REPO_ROOT).as_posix()

PATTERNS = {
    "linux-home": re.compile(r"/home/[^/\s\"']+/"),
    "mac-home": re.compile(r"/Users/[^/\s\"']+/"),
    "root-home": re.compile(r"/root/"),
    "windows-home": re.compile(r"[A-Za-z]:\\\\Users\\\\[^\\\s\"']+\\\\"),
}

SKIP_PATHS = {
    SELF_PATH,
}

STRICT_DIR_PREFIXES = (
    "scripts/",
    ".github/workflows/",
)

STRICT_FILES = {
    "README.md",
    "README.zh-CN.md",
}

SKIP_SUFFIXES = {
    ".png",
    ".jpg",
    ".jpeg",
    ".gif",
    ".webp",
    ".pdf",
    ".tar",
    ".gz",
    ".tgz",
    ".zip",
    ".xz",
    ".bz2",
    ".7z",
    ".pyc",
    ".woff",
    ".woff2",
    ".ttf",
    ".ico",
    ".enc",
}


def iter_tracked_files() -> list[Path]:
    out = subprocess.run(
        ["git", "ls-files", "-z"],
        cwd=REPO_ROOT,
        check=True,
        stdout=subprocess.PIPE,
    ).stdout.decode("utf-8", errors="ignore")
    items = [p for p in out.split("\x00") if p]
    return [REPO_ROOT / p for p in items]


def should_skip(rel_path: str) -> bool:
    if rel_path in SKIP_PATHS:
        return True
    path = Path(rel_path)
    suffixes = path.suffixes
    if any("".join(suffixes[i:]) in {".tar.gz", ".tar.xz", ".tar.bz2"} for i in range(len(suffixes))):
        return True
    return any(rel_path.endswith(suf) for suf in SKIP_SUFFIXES)


def should_scan_strict(rel_path: str) -> bool:
    if rel_path in STRICT_FILES:
        return True
    return rel_path.startswith(STRICT_DIR_PREFIXES)


def main() -> int:
    findings: list[str] = []

    for path in iter_tracked_files():
        rel_path = path.relative_to(REPO_ROOT).as_posix()
        if should_skip(rel_path) or not should_scan_strict(rel_path):
            continue

        try:
            text = path.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            continue

        for lineno, line in enumerate(text.splitlines(), 1):
            if "hardcode-guard: allow" in line:
                continue
            for name, pattern in PATTERNS.items():
                m = pattern.search(line)
                if m:
                    findings.append(f"{rel_path}:{lineno}: [{name}] {m.group(0)}")
                    break

    if findings:
        print("❌ hardcoded user-specific paths detected:")
        for item in findings:
            print(item)
        print("hint: use OPENCLAW_WORKSPACE / WORKSPACE_DIR / $HOME / Path.home() / config/env injection instead")
        return 1

    print("✅ no hardcoded user-specific paths detected")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
