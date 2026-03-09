# Operations Runbook

## Verify cron jobs

```bash
openclaw cron list
```

Expected jobs:
- `memory-sync-daily`
- `memory-weekly-tidy`
- `memory-cron-watchdog`
- `memory-retrieval-watchdog-v1`
- `memory-qmd-nightly-maintain`

## Force-run for smoke test

```bash
openclaw cron run <job-id>
```

If `memory-retrieval-watchdog-v1` is timing out unexpectedly, first verify which model it is using. For lightweight health checks, prefer a stable explicit model (recommended: `glm5`) instead of relying on long fallback chains.

## MVP baseline bootstrap (recommended)

The one-command installer already bootstraps baseline files into workspace:
- `memory/CURRENT_STATE.md`
- `memory/INDEX.md`
- `memory/context-profiles.json`
- `scripts/mem-log.sh`
- `scripts/memory-reflect.sh`
- `scripts/memory_context_budget_guard.py`
- `scripts/memory_context_pack.py`
- `scripts/memory_conflict_check.py`
- `scripts/memory_retrieval_watchdog.py`

Usage examples:

```bash
~/.openclaw/workspace/scripts/mem-log.sh "key decision: ..."
~/.openclaw/workspace/scripts/memory-reflect.sh
```

## Sub-agent task memory practice

- Keep sub-agent raw traces in isolated session history.
- Persist only result-oriented task cards in `memory/tasks/YYYY-MM-DD.md`.
- Recommended card fields: goal, boundary, acceptance, key actions, artifact paths, final status, next step.
- Retrieval order for troubleshooting: task card -> memory search -> raw session history.

## Context budget / dynamic pack quick checks

```bash
# 1) Budget guard
python3 ~/.openclaw/workspace/scripts/memory_context_budget_guard.py --profile main

# 2) See which files are selected under budget
python3 ~/.openclaw/workspace/scripts/memory_context_pack.py --profile main --json

# 3) Durable memory conflict scan
python3 ~/.openclaw/workspace/scripts/memory_conflict_check.py

# 4) Retrieval watchdog one-shot
python3 ~/.openclaw/workspace/scripts/memory_retrieval_watchdog.py --qmd-path "$(command -v qmd)"
```

> In cron / isolated environments, prefer an absolute `qmd` path instead of `$(command -v qmd)` copied from an interactive shell.

## Common failures

1. Gateway timeout while run is actually in progress
   - Re-check with `cron list` for `runningAtMs`
2. Missing QMD binary
   - Verify path in `openclaw.json` or pass `--qmd-path` during install
3. Duplicate memory blocks
   - Verify `processed-sessions.json` is writable and prompt uses fingerprint logic
4. Frequent long silent runs
   - Verify context budget is enforced (`memory_context_budget_guard.py` should be OK)
   - Verify selected profile is minimal (`memory_context_pack.py --json`)
5. Retrieval quality dropped
   - Check `memory-retrieval-watchdog-v1` state and `pending_embeddings`
   - Verify the watchdog model is explicit and stable (recommended: `glm5`)
   - Run `qmd update`; only embed when backlog threshold is exceeded
6. Alert delivery works in one chat but not another
   - Re-check `OPS_TARGET` type (direct chat / group / supergroup)
   - Telegram group upgrades may change chat id; probe the route after install
