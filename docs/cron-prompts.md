# Cron Prompt Reference

This repository ships prompt templates through `scripts/setup.sh`.

## Daily Sync prompt (intent)

- Pull recent sessions
- Filter low-signal sessions
- Compute message fingerprint
- Append concise memory block to today's file
- For sub-agent tasks, write result-only task card to `memory/tasks/YYYY-MM-DD.md`
- Skip noisy isolated raw logs in long-term layers
- Update cursor state
- Run `qmd update`

## Weekly Tidy prompt (intent)

- Read last 7 days + current `MEMORY.md`
- Keep only long-term, action-relevant facts
- Prune stale entries
- Generate weekly summary + archive old logs
- Run `qmd update && qmd embed`

## Watchdog prompt (intent)

- Check `memory-sync-daily`, `memory-weekly-tidy`, `memory-retrieval-watchdog-v1`, and `memory-qmd-nightly-maintain`
- Detect stale/error/disabled states
- Require two consecutive anomalies before alerting
- Include `last3` snapshots in alert payload

## Retrieval watchdog prompt (intent)

- Run `python3 scripts/memory_retrieval_watchdog.py --qmd-path <absolute-qmd-path>`
- Use a stable explicit model for the cron job (recommended: `glm5`)
- Healthy or first anomaly: `ANNOUNCE_SKIP`
- Confirmed anomaly only: send routed alert if `OPS_TARGET` is configured

## Nightly QMD maintenance prompt (intent)

- Run `qmd update`
- Parse `qmd status` pending backlog
- Run `qmd embed` only when pending backlog exceeds threshold
- On failure, alert via configured route; `OPS_TARGET` may be direct chat / group / supergroup
