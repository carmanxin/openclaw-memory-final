# AI Agent Bootstrap Prompt (One-Link Friendly)

Paste this prompt to OpenClaw with the repository URL.

```text
请在当前机器按“可审计、可回滚”的方式部署：
https://github.com/codesfly/openclaw-memory-final

严格按以下步骤执行：
1) clone 仓库到临时目录
2) 执行（单命令安装，AI 友好）：
   bash scripts/install-ai.sh --tz Asia/Shanghai
3) 若返回 `AI_INSTALL_ERROR qmd_not_found`，则停止并提示我提供 qmd 绝对路径
4) 若成功，必须输出 install-ai.sh 返回的 JSON 原文
5) 再执行一次核验：
   - openclaw cron list（确认存在 memory-sync-daily / memory-weekly-tidy / memory-cron-watchdog）
   - 检查 `~/.openclaw/workspace/memory/state/processed-sessions.json`
   - 检查 `~/.openclaw/workspace/memory/state/memory-watchdog-state.json`
6) 最终回报格式：
   - Result: OK/FAIL
   - Jobs: 名称 -> id
   - Next Runs:
   - QMD Path:
   - Warnings:

约束：
- 不修改任何非 memory-* 任务
- 不执行外发消息（除非我明确提供 ops target）
- 不做全量 config.apply 覆盖
```

## Why this is AI-friendly

- Single command (`install-ai.sh`) for deterministic install
- Structured success/error markers (`AI_INSTALL_OK` / `AI_INSTALL_ERROR`)
- Machine-readable JSON output for automated verification
