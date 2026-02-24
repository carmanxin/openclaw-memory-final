# Architecture

## 0) System Diagram

```mermaid
flowchart TD
  U[User Sessions
Direct/Group] --> DS[Daily Sync
memory-sync-daily
23:00]
  DS --> F[Fingerprint Idempotency
processed-sessions.json]
  F --> DLOG[memory/YYYY-MM-DD.md
append-only today]
  DLOG --> Q1[QMD update
daily]

  DLOG --> WT[Weekly Tidy
memory-weekly-tidy
Sun 22:00]
  WT --> LM[MEMORY.md
curated long-term]
  WT --> WS[memory/weekly/YYYY-MM-DD.md]
  WT --> AR[memory/archive/YYYY/]
  WT --> Q2[QMD update + embed
weekly]

  WD[Watchdog
memory-cron-watchdog
*/2h @ :15] --> CJ[(Cron Jobs State)]
  CJ --> ST[memory-watchdog-state.json
consecutive anomalies + last3]
  ST --> DEC{anomaly >= 2?}
  DEC -- no --> SKIP[ANNOUNCE_SKIP]
  DEC -- yes --> ALERT[Send alert
(optional ops target)]
```

## 1) Design goals

- Reliability: memory tasks should self-heal and avoid silent failure
- Idempotency: no duplicate daily memory blocks for same conversation state
- Cost control: avoid unnecessary vector embedding
- Auditability: every decision and status can be traced

## 2) Pipeline

### A. Daily Sync (`memory-sync-daily`)
- Schedule: `0 23 * * *` (local timezone)
- Scope: recent 26 hours of sessions
- Filter: skip sessions with `<2` user messages
- Write target: `memory/YYYY-MM-DD.md` (append-only for today)
- Idempotency key: message fingerprint from last user message

### B. Weekly Tidy (`memory-weekly-tidy`)
- Schedule: `0 22 * * 0`
- Consolidates recent 7-day daily logs into long-term memory
- Enforces `MEMORY.md` constraints (recommended hard cap: 80 lines / 5KB)
- Writes weekly summary: `memory/weekly/YYYY-MM-DD.md` (Monday key)
- Archives covered daily logs: `memory/archive/YYYY/`

### C. Watchdog (`memory-cron-watchdog`)
- Schedule: `15 */2 * * *`
- Detects disabled/stale/error states
- Suppresses transient noise: requires `2` consecutive anomalies
- Adds `last3` snapshots for diagnostics in alerts

## 3) State files

- `memory/state/processed-sessions.json`
  - stores per-session last fingerprint and timestamps
- `memory/state/memory-watchdog-state.json`
  - stores anomaly counters and `last3` snapshots

## 4) QMD strategy

- Daily: `qmd update`
- Weekly: `qmd update && qmd embed`

This keeps retrieval fresh while reducing embedding cost.

## 5) Why this design reduces token cost

- Daily sync runs once per day (instead of high-frequency re-summarization).
- Weekly tidy batches heavy consolidation and embedding.
- Fingerprint idempotency prevents duplicate memory writes.
- Watchdog suppresses noisy one-off anomalies (2-hit confirmation).
