# AI Agent Bootstrap Prompt (One-Link Friendly)

Paste this prompt to OpenClaw together with this repository URL.

```text
请基于仓库 https://github.com/codesfly/openclaw-memory-final 在当前机器完成“可运行”的记忆架构部署，并输出验收结果。

目标：
- 成功部署 3 个 cron：memory-sync-daily / memory-weekly-tidy / memory-cron-watchdog
- 初始化 memory/state 两个状态文件
- 输出可审计结果（任务ID、时区、QMD路径、下次运行时间）

执行要求：
1) clone 仓库到临时目录
2) 自动探测 qmd 路径（command -v qmd）；若失败，明确报错并停止
3) 执行：
   bash scripts/setup.sh --tz Asia/Shanghai --qmd-path <探测到的路径>
   （如我提供了告警群，再追加 --ops-channel/--ops-account/--ops-target）
4) 不覆盖我的业务 cron（仅操作 memory-* 三个任务）
5) 结束前执行验证：
   - openclaw cron list（确认三项存在）
   - 检查 memory/state/processed-sessions.json
   - 检查 memory/state/memory-watchdog-state.json
6) 最终按以下格式回报：
   - Installed: [jobName -> jobId]
   - QMD Path:
   - Next Runs:
   - State Files:
   - Warnings:

注意：
- 不做任何外发消息，除非我明确提供告警 target。
- 不要修改非 memory 相关任务。
```

## Notes

- This prompt is deterministic and tool-oriented.
- It avoids hidden assumptions by requiring explicit verification output.
