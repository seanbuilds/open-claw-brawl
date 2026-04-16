#!/usr/bin/env bash
# open-claw-brawl: Pre-flight verification script
# Run BEFORE starting any OpenClaw installation step.
# Usage: bash scripts/preflight.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASS="${GREEN}✅ PASS${NC}"
FAIL="${RED}❌ FAIL${NC}"
WARN="${YELLOW}⚠️  WARN${NC}"

echo ""
echo "🦀 open-claw-brawl — Pre-flight Check"
echo "========================================"
echo ""

ERRORS=0

# Check 1: Node.js version
NODE_VERSION=$(node -v 2>/dev/null | sed 's/v//')
NODE_MAJOR=$(echo "$NODE_VERSION" | cut -d. -f1)
if [ -z "$NODE_VERSION" ]; then
  echo -e "$FAIL Node.js not found. Install with: brew install node"
  ERRORS=$((ERRORS+1))
elif [ "$NODE_MAJOR" -lt 18 ]; then
  echo -e "$FAIL Node.js $NODE_VERSION found — need ≥ 18. Run: brew upgrade node"
  ERRORS=$((ERRORS+1))
else
  echo -e "$PASS Node.js v$NODE_VERSION"
fi

# Check 2: npm available
NPM_VERSION=$(npm -v 2>/dev/null)
if [ -z "$NPM_VERSION" ]; then
  echo -e "$FAIL npm not found"
  ERRORS=$((ERRORS+1))
else
  echo -e "$PASS npm v$NPM_VERSION"
fi

# Check 3: Ollama running
OLLAMA_RESPONSE=$(curl -s --max-time 3 http://127.0.0.1:11434/api/tags 2>/dev/null)
if [ -z "$OLLAMA_RESPONSE" ]; then
  echo -e "$FAIL Ollama is NOT running. Open Ollama.app first."
  ERRORS=$((ERRORS+1))
else
  echo -e "$PASS Ollama is running"
fi

# Check 4: llama3.2:latest pulled
if echo "$OLLAMA_RESPONSE" | grep -q "llama3.2"; then
  echo -e "$PASS ollama/llama3.2:latest is available"
else
  echo -e "$WARN llama3.2:latest not found. Run: ollama pull llama3.2:latest"
fi

# Check 5: No bad models (70B+)
if echo "$OLLAMA_RESPONSE" | grep -qE "llama3\.3|70b|mixtral|70B"; then
  echo -e "$WARN Large model (70B+) detected in Ollama. This may cause OOM if selected by OpenClaw."
fi

# Check 6: OpenClaw installed
OPENCLAW_VERSION=$(openclaw --version 2>/dev/null)
if [ -z "$OPENCLAW_VERSION" ]; then
  echo -e "$WARN openclaw not installed yet. Run: npm install -g openclaw"
else
  echo -e "$PASS openclaw $OPENCLAW_VERSION installed"
fi

# Check 7: Existing openclaw.json
if [ -f "$HOME/.openclaw/openclaw.json" ]; then
  CONTEXT=$(grep -o '"contextLength":[^,}]*' "$HOME/.openclaw/openclaw.json" 2>/dev/null | head -1)
  echo -e "$WARN Existing openclaw.json found. Verify $CONTEXT is set to 8192."
fi

echo ""
echo "========================================"

if [ "$ERRORS" -gt 0 ]; then
  echo -e "${RED}Pre-flight FAILED with $ERRORS error(s). Fix above before proceeding.${NC}"
  exit 1
else
  echo -e "${GREEN}Pre-flight PASSED. Safe to proceed with installation.${NC}"
fi

echo ""
