#!/usr/bin/env bash
set -euo pipefail

export TZ="${TZ:-Asia/Shanghai}"

if [ $# -lt 1 ]; then
  echo "Usage: $0 <note...>" >&2
  exit 1
fi

workspace="${WORKSPACE_DIR:-$HOME/.openclaw/workspace}"
day="$(date +%F)"
ts="$(date '+%Y-%m-%d %H:%M:%S %z')"
file="$workspace/memory/$day.md"

mkdir -p "$(dirname "$file")"
printf -- "- %s %s\n" "$ts" "$*" >> "$file"

echo "OK -> $file"
