#!/usr/bin/env bash
set -euo pipefail

export TZ="${TZ:-Asia/Shanghai}"

workspace="${WORKSPACE_DIR:-$HOME/.openclaw/workspace}"
day="$(date +%F)"
dst="$workspace/memory/tasks/$day.md"

mkdir -p "$(dirname "$dst")"
{
  echo "## $(date '+%H:%M') 夜间反思"
  echo "- 任务目标："
  echo "- 边界："
  echo "- 验收标准："
  echo "- 关键动作："
  echo "- 产物路径："
  echo "- 最终状态："
  echo "- 下一步："
  echo
} >> "$dst"

echo "OK -> $dst"
