#!/usr/bin/env bash
set -euo pipefail

TZ_VALUE="Asia/Shanghai"
WORKSPACE="${OPENCLAW_WORKSPACE:-$HOME/.openclaw/workspace}"
QMD_PATH="${QMD_PATH:-}"
OPS_CHANNEL="telegram"
OPS_ACCOUNT="ops"
OPS_TARGET=""
CMD_TIMEOUT_SEC="60"
FORCE_RECREATE=0

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
    --command-timeout)
      CMD_TIMEOUT_SEC="$2"; shift 2 ;;
    --force-recreate)
      FORCE_RECREATE=1; shift ;;
    *)
      echo "AI_INSTALL_ERROR unknown_arg=$1"
      exit 2 ;;
  esac
done

if [[ -z "$QMD_PATH" ]]; then
  if command -v qmd >/dev/null 2>&1; then
    QMD_PATH="$(command -v qmd)"
  else
    echo "AI_INSTALL_ERROR qmd_not_found"
    exit 3
  fi
fi

ARGS=(
  --tz "$TZ_VALUE"
  --workspace "$WORKSPACE"
  --qmd-path "$QMD_PATH"
  --command-timeout "$CMD_TIMEOUT_SEC"
  --print-json
)

if [[ -n "$OPS_TARGET" ]]; then
  ARGS+=(--ops-channel "$OPS_CHANNEL" --ops-account "$OPS_ACCOUNT" --ops-target "$OPS_TARGET")
fi
if [[ "$FORCE_RECREATE" -eq 1 ]]; then
  ARGS+=(--force-recreate)
fi

if ! OUT="$(bash "$(dirname "$0")/setup.sh" "${ARGS[@]}" 2>&1)"; then
  echo "AI_INSTALL_ERROR setup_failed"
  echo "$OUT"
  exit 4
fi

echo "AI_INSTALL_OK"
echo "$OUT"
