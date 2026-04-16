# 🦀 open-claw-brawl

> **Battle-hardened OpenClaw deployment on macOS — local-first, zero cloud, WhatsApp-powered multi-agent AI swarms.**

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Node](https://img.shields.io/badge/node-%3E%3D18-brightgreen)
![Platform](https://img.shields.io/badge/platform-macOS-lightgrey)
![Model](https://img.shields.io/badge/model-llama3.2%3Alatest-orange)
![Status](https://img.shields.io/badge/status-active-success)

---

## What Is This?

`open-claw-brawl` is a production-hardened, opinionated deployment framework for [OpenClaw](https://github.com/openclaw) on macOS. It packages the exact 9-step installation sequence, validated configuration templates, and post-mortem learnings from April 2026 into a repeatable, zero-error setup process.

**The stack:**
- 🖥️ **Runtime**: macOS (Apple Silicon + Intel)
- 🧠 **Inference**: [Ollama](https://ollama.com) running `llama3.2:latest` locally — no cloud, no API keys, no rate limits
- 🤖 **Swarm**: OpenClaw multi-agent CLI (`npm install -g openclaw`)
- 📱 **Channel**: WhatsApp (via `openclaw gateway` + QR pair)
- 🛠️ **IDE**: [Google Antigravity](https://antigravity.dev) for agent orchestration

---

## Why This Exists

Standard OpenClaw installations frequently fail due to:
- Wrong model selection (e.g. `llama3.3:latest` or any 70B+ model causing OOM)
- `contextLength` set too high (causes gateway instability)
- Gateway and test scripts running simultaneously (port conflicts)
- WhatsApp credentials wiped prematurely

This repo encodes **every hard lesson** from those failures into a strict 9-step sequence that eliminates them.

---

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Node.js | ≥ 18 | `brew install node` |
| npm | ≥ 9 | (bundled with Node) |
| Ollama.app | latest | [ollama.com](https://ollama.com) |
| Git | any | `brew install git` |

> ⚠️ **Ollama must be running AND logged in before any OpenClaw command.**

---

## Quick Start

```bash
# 1. Clone this repo
git clone https://github.com/YOUR_USERNAME/open-claw-brawl.git
cd open-claw-brawl

# 2. Run the pre-flight check
bash scripts/preflight.sh

# 3. Follow the 9-step sequence in docs/INSTALL_SEQUENCE.md
```

---

## The 9-Step Install Sequence

See [`docs/INSTALL_SEQUENCE.md`](docs/INSTALL_SEQUENCE.md) for the full, annotated sequence. Summary:

| Step | Action |
|------|--------|
| 1 | Verify Ollama is running (`curl http://127.0.0.1:11434/api/tags`) |
| 2 | Pull `llama3.2:latest` if missing |
| 3 | `npm install -g openclaw` |
| 4 | `openclaw configure` (set `OLLAMA_API_KEY=ollama-local`, skip cloud) |
| 5 | Edit `openclaw.json` — force all agents to `ollama/llama3.2:latest`, set `contextLength: 8192` |
| 6 | `openclaw gateway` — confirm `[whatsapp] Listening…` |
| 7 | `openclaw channels login` — QR scan WhatsApp |
| 8 | Send one `"hi"` from WhatsApp — verify clean reply |
| 9 | Run multi-agent test (only after step 8 passes) |

---

## Hard Rules (Never Violate)

- ✅ **Only** use `ollama/llama3.2:latest` for supervisor AND all agents
- ✅ **Always** cap `contextLength` at exactly `8192`
- ✅ Ollama must be **fully running** before any `openclaw` command
- ❌ **Never** run the gateway and a test script simultaneously
- ❌ **Never** wipe `~/.openclaw/credentials/whatsapp/` unless pairing is confirmed broken

---

## Project Structure

```
open-claw-brawl/
├── README.md
├── LICENSE
├── CONTRIBUTING.md
├── .gitignore
├── package.json
├── config/
│   └── openclaw.template.json   # Safe, validated config template
├── docs/
│   ├── INSTALL_SEQUENCE.md      # Full 9-step annotated guide
│   └── POST_MORTEM_APR2026.md   # Root cause analysis from April 2026
├── prompts/
│   └── openclaw_supervisor_v2026.txt  # Antigravity supervisor agent prompt
└── scripts/
    ├── preflight.sh             # Pre-install verification script
    └── verify.sh                # Post-install health check
```

---

## Configuration Template

Use [`config/openclaw.template.json`](config/openclaw.template.json) as your base. **Never** modify `contextLength` above 8192.

---

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md). PRs welcome for:
- Additional channel adapters
- Improved preflight checks
- Other macOS-specific hardening

---

## License

MIT — see [`LICENSE`](LICENSE)

---

## Post-Mortem

The full April 2026 failure analysis is documented in [`docs/POST_MORTEM_APR2026.md`](docs/POST_MORTEM_APR2026.md). Read it before opening issues.
