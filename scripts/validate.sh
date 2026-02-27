#!/usr/bin/env bash
set -euo pipefail

# shell syntax
bash -n scripts/setup.sh
bash -n scripts/uninstall.sh
bash -n scripts/install-ai.sh
bash -n scripts/mem-log.sh
bash -n scripts/memory-reflect.sh

# json validity
jq empty examples/openclaw-memory-config.patch.json
jq empty examples/memory/state/processed-sessions.json
jq empty examples/memory/state/memory-watchdog-state.json

echo "✅ validation passed"
