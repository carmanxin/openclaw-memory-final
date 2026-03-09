#!/usr/bin/env python3
"""Memory context budget guard.

Checks core memory/context files size against per-file and total budgets,
and writes machine-readable state for watchdog/reporting.
"""

import argparse
import datetime as dt
import json
import os
from pathlib import Path


def default_workspace() -> Path:
    ws = os.environ.get("OPENCLAW_WORKSPACE")
    return Path(ws).expanduser() if ws else Path.home() / ".openclaw" / "workspace"


def read_text_len(p: Path) -> int:
    if not p.exists() or not p.is_file():
        return 0
    return len(p.read_text(encoding="utf-8", errors="ignore"))


def main() -> int:
    ap = argparse.ArgumentParser(description="Memory context budget guard")
    ap.add_argument("--workspace", default=str(default_workspace()))
    ap.add_argument("--max-per-file", type=int, default=20000)
    ap.add_argument("--max-total", type=int, default=80000)
    ap.add_argument("--profile", default="main")
    ap.add_argument("--state")
    args = ap.parse_args()

    ws = Path(args.workspace).expanduser()
    state_path = Path(args.state).expanduser() if args.state else ws / "memory" / "state" / "context-budget-state.json"
    now = dt.datetime.now()
    today = now.strftime("%Y-%m-%d")
    yesterday = (now - dt.timedelta(days=1)).strftime("%Y-%m-%d")

    files = [
        ws / "SOUL.md",
        ws / "USER.md",
        ws / "AGENTS.md",
        ws / "MEMORY.md",
        ws / "memory" / f"{today}.md",
        ws / "memory" / f"{yesterday}.md",
    ]

    details = []
    anomalies = []
    total = 0
    for f in files:
        n = read_text_len(f)
        total += n
        details.append({"file": str(f), "chars": n, "exists": f.exists()})
        if n > args.max_per_file:
            anomalies.append(f"file_over_budget:{f.name}:{n}>{args.max_per_file}")

    if total > args.max_total:
        anomalies.append(f"total_over_budget:{total}>{args.max_total}")

    out = {
        "ts": now.isoformat(),
        "profile": args.profile,
        "max_per_file": args.max_per_file,
        "max_total": args.max_total,
        "total_chars": total,
        "details": details,
        "anomalies": anomalies,
        "ok": len(anomalies) == 0,
    }

    state_path.parent.mkdir(parents=True, exist_ok=True)
    state_path.write_text(json.dumps(out, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    if out["ok"]:
        print(f"OK total={total} anomalies=0")
        return 0
    print("ANOMALY " + " | ".join(anomalies))
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
