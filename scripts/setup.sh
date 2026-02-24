#!/usr/bin/env bash
set -euo pipefail

TZ_VALUE="${TZ:-Asia/Shanghai}"
WORKSPACE="${OPENCLAW_WORKSPACE:-$HOME/.openclaw/workspace}"
QMD_PATH="${QMD_PATH:-}"
OPS_CHANNEL="${OPS_CHANNEL:-telegram}"
OPS_ACCOUNT="${OPS_ACCOUNT:-ops}"
OPS_TARGET="${OPS_TARGET:-}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tz)
      TZ_VALUE="$2"; shift 2 ;;
    --workspace)
      WORKSPACE="$2"; shift 2 ;;
    --qmd-path)
      QMD_PATH="$2"; shift 2 ;;
    --ops-channel)
      OPS_CHANNEL="$2"; shift 2 ;;
    --ops-account)
      OPS_ACCOUNT="$2"; shift 2 ;;
    --ops-target)
      OPS_TARGET="$2"; shift 2 ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1 ;;
  esac
done

if ! command -v openclaw >/dev/null 2>&1; then
  echo "openclaw CLI not found" >&2
  exit 1
fi

if [[ -z "$QMD_PATH" ]]; then
  if command -v qmd >/dev/null 2>&1; then
    QMD_PATH="$(command -v qmd)"
  else
    echo "qmd not found. Pass --qmd-path /absolute/path/to/qmd" >&2
    exit 1
  fi
fi

if [[ ! -x "$QMD_PATH" ]]; then
  echo "qmd path is not executable: $QMD_PATH" >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

mkdir -p "$WORKSPACE/memory/weekly" "$WORKSPACE/memory/archive/$(date +%Y)" "$WORKSPACE/memory/state"

if [[ ! -f "$WORKSPACE/memory/state/processed-sessions.json" ]]; then
  cp "$REPO_ROOT/examples/memory/state/processed-sessions.json" "$WORKSPACE/memory/state/processed-sessions.json"
fi
if [[ ! -f "$WORKSPACE/memory/state/memory-watchdog-state.json" ]]; then
  cp "$REPO_ROOT/examples/memory/state/memory-watchdog-state.json" "$WORKSPACE/memory/state/memory-watchdog-state.json"
fi

get_job_ids_by_name() {
  local name="$1"
  local json
  json="$(openclaw cron list --json 2>/dev/null || echo '{"jobs":[]}')"
  python3 - "$name" <<'PY' <<<"$json"
import json, sys
name = sys.argv[1]
raw = sys.stdin.read().strip() or '{"jobs":[]}'
try:
    data = json.loads(raw)
except Exception:
    data = {"jobs": []}
for job in data.get("jobs", []):
    if job.get("name") == name and job.get("id"):
        print(job["id"])
PY
}

remove_jobs_by_name() {
  local name="$1"
  local ids
  ids="$(get_job_ids_by_name "$name" || true)"
  if [[ -n "$ids" ]]; then
    while IFS= read -r id; do
      [[ -z "$id" ]] && continue
      openclaw cron remove "$id" >/dev/null 2>&1 || true
    done <<<"$ids"
  fi
}

for name in memory-sync-daily memory-weekly-tidy memory-cron-watchdog; do
  remove_jobs_by_name "$name"
done

DAILY_MSG="MEMORY DAILY SYNC — 你是每日记忆蒸馏 agent。读取最近26小时会话，跳过<2条用户消息和isolated噪音会话。使用最后用户消息timestamp+文本前120字符作为fingerprint；若与memory/state/processed-sessions.json中lastFingerprint一致则跳过。仅将新增会话摘要追加到memory/YYYY-MM-DD.md（3-8条要点）。更新state后执行 QMD_GPU=cpu $QMD_PATH update。完成回复ANNOUNCE_SKIP。"

WEEKLY_MSG="MEMORY WEEKLY TIDY — 你是每周记忆巩固 agent。聚合近7天daily日志，精炼MEMORY.md（<=80行/5KB），生成memory/weekly/YYYY-MM-DD.md并归档覆盖的旧daily。执行 QMD_GPU=cpu $QMD_PATH update && QMD_GPU=cpu $QMD_PATH embed。无变更回复ANNOUNCE_SKIP。"

if [[ -n "$OPS_TARGET" ]]; then
  WATCHDOG_NOTIFY="若confirmed anomaly，使用message工具发送到 $OPS_CHANNEL（accountId=$OPS_ACCOUNT, target=$OPS_TARGET），并附异常项/连续次数/自愈动作/最近3次快照。"
else
  WATCHDOG_NOTIFY="若confirmed anomaly，记录状态并回复ANNOUNCE_SKIP（未配置外部告警目标）。"
fi

WATCHDOG_MSG="你是memory watchdog。检查memory-sync-daily与memory-weekly-tidy是否enabled、lastStatus非error/failed、且未stale。维护memory/state/memory-watchdog-state.json中的consecutiveAnomalies和last3快照。仅连续2次异常才算confirmed anomaly；首轮异常只计数不告警。$WATCHDOG_NOTIFY 完成回复ANNOUNCE_SKIP。"

openclaw cron add \
  --name "memory-sync-daily" \
  --cron "0 23 * * *" \
  --tz "$TZ_VALUE" \
  --session isolated \
  --agent main \
  --timeout-seconds 300 \
  --no-deliver \
  --message "$DAILY_MSG"

openclaw cron add \
  --name "memory-weekly-tidy" \
  --cron "0 22 * * 0" \
  --tz "$TZ_VALUE" \
  --session isolated \
  --agent main \
  --timeout-seconds 600 \
  --no-deliver \
  --message "$WEEKLY_MSG"

openclaw cron add \
  --name "memory-cron-watchdog" \
  --cron "15 */2 * * *" \
  --tz "$TZ_VALUE" \
  --session isolated \
  --agent main \
  --timeout-seconds 180 \
  --no-deliver \
  --message "$WATCHDOG_MSG"

echo "✅ Installed memory architecture jobs"
echo "timezone=$TZ_VALUE workspace=$WORKSPACE qmd=$QMD_PATH"
if [[ -n "$OPS_TARGET" ]]; then
  echo "watchdog alert target: $OPS_CHANNEL/$OPS_ACCOUNT/$OPS_TARGET"
else
  echo "watchdog alert target: disabled"
fi
openclaw cron list
