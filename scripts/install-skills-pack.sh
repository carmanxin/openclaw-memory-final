#!/usr/bin/env bash
set -euo pipefail

WORKSPACE="${OPENCLAW_WORKSPACE:-$HOME/.openclaw/workspace}"
BUNDLE_PATH=""
VERIFY=1

usage() {
  cat <<'EOF'
Usage: bash scripts/install-skills-pack.sh [options]

Options:
  --workspace <path>   Target OpenClaw workspace (default: ~/.openclaw/workspace)
  --bundle <path>      Path to skills tarball (default: latest examples/skills/openclaw-skills-pack-*.tar.gz)
  --no-verify          Skip `openclaw skills list --eligible`
  -h, --help           Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --workspace)
      WORKSPACE="$2"; shift 2 ;;
    --bundle)
      BUNDLE_PATH="$2"; shift 2 ;;
    --no-verify)
      VERIFY=0; shift ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1 ;;
  esac
done

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [[ -z "$BUNDLE_PATH" ]]; then
  BUNDLE_PATH="$(ls -1 "$REPO_ROOT"/examples/skills/openclaw-skills-pack-*.tar.gz 2>/dev/null | sort | tail -n1 || true)"
fi

if [[ -z "$BUNDLE_PATH" || ! -f "$BUNDLE_PATH" ]]; then
  echo "SKILLS_INSTALL_ERROR bundle_not_found" >&2
  echo "hint: pass --bundle /absolute/path/to/openclaw-skills-pack-*.tar.gz" >&2
  exit 2
fi

SKILLS_DIR="$WORKSPACE/skills"
mkdir -p "$SKILLS_DIR"

mapfile -t SKILL_FILES < <(tar -tzf "$BUNDLE_PATH" | grep -E '\.skill$' || true)
if [[ "${#SKILL_FILES[@]}" -eq 0 ]]; then
  echo "SKILLS_INSTALL_ERROR no_skill_files_in_bundle" >&2
  exit 3
fi

tar -xzf "$BUNDLE_PATH" -C "$SKILLS_DIR"

if [[ "$VERIFY" -eq 1 ]]; then
  if command -v openclaw >/dev/null 2>&1; then
    if ! openclaw skills list --eligible >/tmp/openclaw-skills-eligible.txt 2>&1; then
      echo "SKILLS_INSTALL_WARN verify_failed" >&2
      echo "hint: run 'openclaw skills list --eligible' manually" >&2
    fi
  else
    echo "SKILLS_INSTALL_WARN openclaw_cli_not_found_skip_verify" >&2
  fi
fi

python3 - "$WORKSPACE" "$SKILLS_DIR" "$BUNDLE_PATH" "${#SKILL_FILES[@]}" <<'PY'
import json, sys
workspace, skills_dir, bundle, count = sys.argv[1:]
out = {
  "ok": True,
  "workspace": workspace,
  "skillsDir": skills_dir,
  "bundle": bundle,
  "installedCount": int(count),
  "note": "start a new session to pick up updated skills snapshot"
}
print("SKILLS_INSTALL_OK")
print(json.dumps(out, ensure_ascii=False))
PY
