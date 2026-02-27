# Operations Runbook

## Verify cron jobs

```bash
openclaw cron list
```

Expected jobs:
- `memory-sync-daily`
- `memory-weekly-tidy`
- `memory-cron-watchdog`

## Force-run for smoke test

```bash
openclaw cron run <job-id>
```

## MVP baseline bootstrap (recommended)

The one-command installer already bootstraps baseline files into workspace:
- `memory/CURRENT_STATE.md`
- `memory/INDEX.md`
- `scripts/mem-log.sh`
- `scripts/memory-reflect.sh`

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

## Common failures

1. Gateway timeout while run is actually in progress
   - Re-check with `cron list` for `runningAtMs`
2. Missing QMD binary
   - Verify path in `openclaw.json`
3. Duplicate memory blocks
   - Verify `processed-sessions.json` is writable and prompt uses fingerprint logic
