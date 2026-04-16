# Post-Mortem: OpenClaw Deployment Failures — April 16, 2026

**Author:** Sean Tyler  
**Status:** Resolved  
**Severity:** P1 — Production swarm offline

---

## Executive Summary

A series of OpenClaw deployment attempts on macOS resulted in repeated gateway crashes, WhatsApp pairing failures, and agent OOM kills. Root cause analysis identified four compounding issues, all of which are now encoded as hard rules in this repository.

---

## Incident Timeline

| Time | Event |
|------|-------|
| T+0 | Initial `openclaw configure` run — cloud providers misconfigured |
| T+30m | Gateway started, crashed within 60s |
| T+45m | WhatsApp credentials wiped prematurely — required full re-pair |
| T+1h | Second gateway start — OOM kill due to wrong model |
| T+2h | Third attempt — port conflict from simultaneous test run |
| T+3h | Clean 9-step sequence established — system stable |

---

## Root Causes

### RC-1: Wrong Model (`llama3.3:latest` / 70B+)

**What happened:** `openclaw configure` defaulted to `llama3.3:latest` which requires ~40GB RAM. This caused the gateway process to be OOM-killed by macOS within seconds of starting.

**Fix:** Hard-code `ollama/llama3.2:latest` in every agent entry in `openclaw.json` before starting the gateway.

---

### RC-2: `contextLength` Set Too High

**What happened:** Default `contextLength` was set to `32768`. Combined with 6 agents, this caused rapid memory exhaustion.

**Fix:** Always set `"contextLength": 8192` in the defaults section. This is the maximum safe value for `llama3.2:latest` on macOS.

---

### RC-3: Gateway and Test Script Running Simultaneously

**What happened:** Running `openclaw swarm test` in a second terminal while the gateway was running caused a port conflict on `3000`, crashing both processes.

**Fix:** Never run any openclaw command concurrently with the gateway. Use separate, sequential terminal sessions.

---

### RC-4: Premature WhatsApp Credential Wipe

**What happened:** Attempting to fix a disconnection by deleting `~/.openclaw/credentials/whatsapp/` without confirming the root cause. This forced a full re-pair cycle and extended the outage by 45 minutes.

**Fix:** Only wipe WhatsApp credentials when the user has explicitly confirmed that QR pairing has failed completely and no other fix is possible.

---

## Changes Made (Encoded in This Repo)

- [x] `docs/INSTALL_SEQUENCE.md` — strict 9 steps, ordered, gated on verification
- [x] `config/openclaw.template.json` — safe defaults, `llama3.2:latest`, `contextLength: 8192`
- [x] `scripts/preflight.sh` — automated checks before any install step
- [x] `prompts/openclaw_supervisor_v2026.txt` — Antigravity supervisor agent with all hard rules
- [x] `README.md` — hard rules surfaced prominently

---

## Lessons Learned

1. **Always verify Ollama is running before touching OpenClaw** — the CLI gives misleading errors when Ollama is offline
2. **Model selection is the #1 failure point** — always confirm `ollama list` shows only `llama3.2:latest` before proceeding
3. **Don't touch credentials unless explicitly asked** — WhatsApp re-pairing is painful and avoidable
4. **Gate every step on verified output** — don't assume a command succeeded because it didn't error

---

*Document closed: April 16, 2026*
