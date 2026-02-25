## Memory (Production Pattern)

You wake up fresh each session. Files are your memory.

### Session startup sequence

1. Read `SOUL.md`
2. Read `USER.md`
3. Read today's and yesterday's daily memory logs
4. In direct/private main session only: read `MEMORY.md`

### Three-layer memory model

- Daily logs: `memory/YYYY-MM-DD.md`
- Weekly summaries: `memory/weekly/YYYY-MM-DD.md` (Monday key)
- Long-term memory: `MEMORY.md` (strictly curated)

### Long-term memory constraints

- Keep `MEMORY.md` concise and actionable
- Recommended hard cap: 80 lines / 5KB
- Compress/merge before adding if near cap

### Sub-agent task memory (result-only)

- Keep sub-agent raw process in isolated session history.
- Persist only reusable outcomes into `memory/tasks/YYYY-MM-DD.md`.
- Suggested fields: goal, boundary, acceptance, key actions, artifact paths, final status, next step.

### Retrieval order

1. Check `memory/tasks/*.md` first
2. Then run semantic memory search
3. Drill into raw session history only when needed

### Write-now rule

When key decisions or durable user preferences appear, append to today's daily memory immediately.
Do not rely on cron alone.

### Safety

Never write tokens/secrets/private identifiers into memory files.
