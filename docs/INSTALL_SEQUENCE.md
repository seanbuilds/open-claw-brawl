# OpenClaw Clean Install — Full 9-Step Sequence

> Validated on macOS (Apple Silicon + Intel) · April 2026  
> Runtime: Ollama.app · Model: `llama3.2:latest` · Channel: WhatsApp

---

## Before You Start

- ✅ Ollama.app is **open and running** (check menu bar icon)
- ✅ Node.js ≥ 18 is installed (`node -v`)
- ✅ You have NOT run any prior `openclaw` commands in this session
- ✅ WhatsApp is accessible on your phone for QR scanning

---

## Step 1 — Verify Ollama Is Running

```bash
curl http://127.0.0.1:11434/api/tags
```

**Expected:** Valid JSON listing your local models.

**If it fails:** Open Ollama.app from your Applications folder. Wait 10 seconds. Retry.

> ❌ Do NOT proceed to Step 2 until this returns valid JSON.

---

## Step 2 — Pull llama3.2:latest (if missing)

```bash
ollama pull llama3.2:latest
```

**Expected:** `pulling manifest` → progress bars → `success`

Check the model list shows it:
```bash
ollama list
```

> ⚠️ ONLY pull `llama3.2:latest`. Never pull `llama3.3:latest` or any 70B+ model — they will cause out-of-memory crashes.

---

## Step 3 — Install OpenClaw CLI

```bash
npm install -g openclaw
```

**Expected:** Clean install with no `EACCES` errors.

Verify:
```bash
openclaw --version
```

---

## Step 4 — Configure OpenClaw

```bash
openclaw configure
```

When prompted:
- `OLLAMA_API_KEY` → enter: `ollama-local`
- All cloud provider prompts (OpenAI, Anthropic, etc.) → **skip / leave blank**

---

## Step 5 — Edit openclaw.json (CRITICAL)

Your config lives at `~/.openclaw/openclaw.json`. Open it and make **two mandatory changes**:

### 5a. Set every agent model to `ollama/llama3.2:latest`

Every agent entry that has a `model` field must be set to:
```json
"model": "ollama/llama3.2:latest"
```

### 5b. Set contextLength in the defaults section

```json
"defaults": {
  "contextLength": 8192
}
```

> ⚠️ `contextLength` must be **exactly 8192**. Higher values cause gateway instability and OOM crashes.

Use the validated template at [`../config/openclaw.template.json`](../config/openclaw.template.json) as a reference.

---

## Step 6 — Start the Gateway

```bash
openclaw gateway
```

**Expected output must include:**
```
[whatsapp] Listening…
```

Keep this terminal window open. **Do NOT run any other openclaw commands in this window.**

> ❌ If you see errors, stop here. Paste the full output and diagnose before continuing.

---

## Step 7 — Link WhatsApp

Open a **new** terminal window (gateway must stay running):

```bash
openclaw channels login
```

- A QR code will appear in your terminal
- Open WhatsApp on your phone → Settings → Linked Devices → Link a Device
- Scan the QR code

**Expected:** `[whatsapp] Connected ✓`

---

## Step 8 — Send the "hi" Test (Required)

From your WhatsApp phone, send a single message to your linked number:

```
hi
```

Wait for a clean reply from the swarm.

> ✅ **Only after receiving a clean reply is the installation considered successful.**  
> ❌ Do NOT run Step 9 until this passes.

---

## Step 9 — Multi-Agent Test (Optional)

Only after Step 8 passes:

```bash
openclaw swarm test
```

**Expected:** All agents respond without errors.

---

## Troubleshooting

| Symptom | Root Cause | Fix |
|---------|-----------|-----|
| Gateway crashes immediately | Wrong model or contextLength too high | Revert to `llama3.2:latest` + `contextLength: 8192` |
| QR code never appears | Gateway not running | Check Step 6 terminal is still active |
| WhatsApp disconnects | Credentials corrupted | Only wipe `~/.openclaw/credentials/whatsapp/` after confirming with user |
| OOM / SIGKILL | 70B+ model loaded | Run `ollama list`, remove large models |
| Port conflict | Gateway + test running simultaneously | Kill all openclaw processes, restart gateway only |

---

*Last validated: April 16, 2026*
