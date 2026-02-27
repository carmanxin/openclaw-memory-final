# Gateway Troubleshooting (Post-Install)

If deployment is slow or gateway seems down after setup:

## 1) Fast health check

```bash
openclaw status
openclaw gateway status
openclaw doctor --non-interactive
```

## 2) Typical causes

1. **Config overwrite mistake**
   - Symptom: gateway cannot start after editing `openclaw.json`
   - Fix: restore backup, then use `config.patch` (not full replace)

2. **Long-running CLI call / timeout**
   - Symptom: setup appears hanging
   - Fix: rerun with higher timeout:
     ```bash
     bash scripts/setup.sh --command-timeout 60 --qmd-path "$(command -v qmd)"
     ```

3. **QMD missing or invalid path**
   - Symptom: `AI_INSTALL_ERROR qmd_not_found` or memory jobs fail repeatedly
   - Fix:
     ```bash
     npm install -g @tobilu/qmd
     qmd --version
     bash scripts/setup.sh --qmd-path "$(command -v qmd)"
     ```
   - If running in isolated/cron environment, prefer absolute path (example):
     ```bash
     bash scripts/setup.sh --qmd-path /home/jiumu/.nvm/versions/node/v22.22.0/bin/qmd
     ```

## 3) Recovery

```bash
openclaw gateway restart
openclaw cron list
```

If still failing, remove memory jobs and reinstall:

```bash
bash scripts/uninstall.sh
bash scripts/setup.sh --qmd-path "$(command -v qmd)"
```
