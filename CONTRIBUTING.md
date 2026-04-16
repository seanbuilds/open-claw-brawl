# Contributing to open-claw-brawl

Thanks for helping make OpenClaw deployments less painful. Here's how to contribute.

## What We Welcome

- 🐛 Bug fixes for the install scripts (`preflight.sh`, `verify.sh`)
- 📝 Documentation improvements (cleaner error messages, better troubleshooting steps)
- 🔧 Improvements to `config/openclaw.template.json`
- 🆕 New channel adapters (Telegram, Slack, etc.) — open an issue first
- 🍎 macOS-version-specific fixes (Ventura, Sonoma, Sequoia)

## What We Don't Accept

- Any change that allows `contextLength` > 8192
- Any change that adds non-`llama3.2:latest` models as defaults
- Cloud provider integrations (this repo is explicitly local-first)

## Process

1. Fork the repo
2. Create a branch: `git checkout -b fix/your-fix-name`
3. Make your changes
4. Test with `bash scripts/preflight.sh` and `bash scripts/verify.sh`
5. Open a PR with a clear description of what you changed and why

## Reporting Issues

When reporting a bug, always include:
- macOS version (`sw_vers`)
- Node version (`node -v`)
- Ollama version (from Ollama.app → About)
- Full terminal output of the failing command
- Contents of `~/.openclaw/openclaw.json` (redact any API keys)

## Code Style

- Shell scripts: POSIX-compatible `bash`, `set -e`, clear variable names
- JSON: 2-space indent, `_comment` fields for context
- Markdown: sentence case headings, tables for structured info
