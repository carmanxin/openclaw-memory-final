# 用户更新文案模板（v0.4.1）

可直接对外发布：

---

🚀 **OpenClaw Memory v0.4.1 已发布**

这次是一个 **patch 稳定性版本**，重点补齐了“轻量 cron 稳定性 + 安装路由说明 + 新版检索约束”三件事：

1) **retrieval watchdog 默认模型显式化**  
- 新增 `--retrieval-model`
- `memory-retrieval-watchdog-v1` 默认显式使用 `glm5`
- 目标：避免轻量巡检任务被模型 fallback 链拖慢甚至超时

2) **QMD 路径说明更硬**  
- 明确建议在 cron / isolated 环境使用绝对 `--qmd-path`
- 避免 interactive shell 能跑、隔离任务里却找不到 `qmd`

3) **告警路由兼容私聊 / 群 / supergroup**  
- 文档明确 `OPS_TARGET` 可以是私聊、群或 supergroup
- 安装后建议做一次 dry-run / real probe，防止群升级后 chat id 失效

4) **检索顺序与新版 OpenClaw 约束对齐**  
- 推荐顺序更新为：`memory/tasks -> memory_search -> memory_get`
- 更适合当前的任务卡优先 + 语义检索 + 精准片段读取流程

5) **安装与运维文档同步更新**  
- README（中英文）、operations runbook、cron prompt reference、AI bootstrap prompt、AGENTS 示例已同步更新
- 降低新环境安装后“能装上但跑不稳”的概率

📦 Release: <https://github.com/codesfly/openclaw-memory-final/releases/tag/v0.4.1>

---

## 短版（适合群里/频道）

🚀 **OpenClaw Memory v0.4.1 已发布**

这次是稳定性补丁版，主要更新：
- `memory-retrieval-watchdog-v1` 默认显式使用 `glm5`
- 强化 cron / isolated 环境下绝对 `qmd` 路径说明
- 明确 `OPS_TARGET` 支持私聊 / 群 / supergroup
- 推荐检索顺序更新为 `memory/tasks -> memory_search -> memory_get`

📦 Release: <https://github.com/codesfly/openclaw-memory-final/releases/tag/v0.4.1>

---

备注：可按渠道再删减为 3 条 bullet 的极短版。
