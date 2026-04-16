#!/usr/bin/env bash
# open-claw-brawl: Post-install health verification script
# Run AFTER completing the 9-step sequence.
# Usage: bash scripts/verify.sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS="${GREEN}✅ PASS${NC}"
FAIL="${RED}❌ FAIL${NC}"
WARN="${YELLOW}⚠️  WARN${NC}"

echo ""
echo "🦀 open-claw-brawl — Post-Install Health Check"
echo "================================================="
echo ""

ERRORS=0

# Check 1: Ollama still running
OLLAMA_RESPONSE=$(curl -s --max-time 3 http://127.0.0.1:11434/api/tags 2>/dev/null)
if [ -z "$OLLAMA_RESPONSE" ]; then
  echo -e "$FAIL Ollama is not running"
  ERRORS=$((ERRORS+1))
else
  echo -e "$PASS Ollama is running"
fi

# Check 2: llama3.2:latest still there
if echo "$OLLAMA_RESPONSE" | grep -q "llama3.2"; then
  echo -e "$PASS llama3.2:latest present"
else
  echo -e "$FAIL llama3.2:latest missing"
  ERRORS=$((ERRORS+1))
fi

# Check 3: openclaw.json exists
if [ ! -f "$HOME/.openclaw/openclaw.json" ]; then
  echo -e "$FAIL ~/.openclaw/openclaw.json not found — did you run openclaw configure?"
  ERRORS=$((ERRORS+1))
else
  echo -e "$PASS openclaw.json exists"

  # Check contextLength
  CTX=$(grep -o '"contextLength":[[:space:]]*[0-9]*' "$HOME/.openclaw/openclaw.json" 2>/dev/null | grep -o '[0-9]*' | head -1)
  if [ "$CTX" = "8192" ]; then
    echo -e "$PASS contextLength = 8192"
  elif [ -z "$CTX" ]; then
    echo -e "$WARN contextLength not found in config — add it manually"
  else
    echo -e "$FAIL contextLength = $CTX (must be 8192)"
    ERRORS=$((ERRORS+1))
  fi

  # Check for wrong models
  if grep -q "llama3.3\|70b\|70B" "$HOME/.openclaw/openclaw.json" 2>/dev/null; then
    echo -e "$FAIL Wrong model detected in openclaw.json (must be llama3.2:latest only)"
    ERRORS=$((ERRORS+1))
  else
    echo -e "$PASS No forbidden models in openclaw.json"
  fi
fi

# Check 4: WhatsApp credentials dir exists
if [ -d "$HOME/.openclaw/credentials/whatsapp" ]; then
  echo -e "$PASS WhatsApp credentials directory exists"
else
  echo -e "$WARN WhatsApp not yet paired (run: openclaw channels login)"
fi

echo ""
echo "================================================="

if [ "$ERRORS" -gt 0 ]; then
  echo -e "${RED}Health check FAILED with $ERRORS error(s). Review above before testing WhatsApp.${NC}"
  exit 1
else
  echo -e "${GREEN}Health check PASSED. System looks good — send your 'hi' test now!${NC}"
fi

echo ""
