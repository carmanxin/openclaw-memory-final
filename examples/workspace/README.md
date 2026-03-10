# Workspace Templates (Sanitized)

This directory ships **sanitized** workspace templates from a real production setup.

## What's included

- `SOUL.md.template` — persona / operating principles
- `AGENTS.md.example` — working agreement and guardrails
- `HEARTBEAT.md.example` — heartbeat checklist
- `USER.md.template` — user preferences template (safe defaults)
- `TOOLS.md.example` — environment notes template (must be redacted before sharing)
- `MEMORY.md.example` — long-term memory template (must be redacted before sharing)

## Safety rules (critical)

Before publishing your own workspace templates, **remove**:

- any IPs / hostnames / ports / internal URLs
- any chat ids (Telegram/Discord/Slack), bot usernames, account ids
- any absolute local paths that contain a username (e.g. `/home/<USER>/...`, `/Users/<USER>/...`)
- any API keys/tokens (obvious, but easy to miss)

This repo keeps templates portable by using:

- `~/.openclaw/workspace` or `$HOME/...`
- `OPENCLAW_WORKSPACE` env var
- config/env injection instead of hardcoded paths

## How to use

Copy files into your OpenClaw workspace and adjust to your needs:

```bash
cp -n examples/workspace/SOUL.md.template ~/.openclaw/workspace/SOUL.md
cp -n examples/workspace/USER.md.template ~/.openclaw/workspace/USER.md
# AGENTS/HEARTBEAT/MEMORY/TOOLS are examples: review and redact before use
```
