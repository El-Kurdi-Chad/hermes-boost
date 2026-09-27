#!/usr/bin/env bash
# ============================================================================
#  Hermes Boost Pack - https://github.com/El-Kurdi-Chad/hermes-boost
#  Boosts an existing Hermes Agent install to its full potential:
#  capabilities (vision, video, voice, desktop control), curated skills,
#  the Playwright MCP server - then verifies everything.
#  Additive & idempotent: nothing is removed, safe to re-run.
#
#  Usage:  bash boost.sh [--dry-run] [--update] [--no-mcp]
#    --dry-run   show what would happen, change nothing
#    --update    also update Hermes itself first (hermes update -y)
#    --no-mcp    skip the optional Playwright MCP server
#
#  Read this file before running it - it is short and plain.
# ============================================================================
set -u
REPO="El-Kurdi-Chad/hermes-boost"
SKILLS="hermes-boost hermes-skill-install hermes-self-maintenance session-librarian deep-research html-artifact ocr-and-documents convert-documents-to-markdown spotify macos-computer-use hermes-bot-profiles"
TOOLSETS="vision video stt video_gen computer_use"
PLATFORMS="cli telegram discord slack whatsapp signal matrix email sms"
DRY=0; DO_UPDATE=0; NO_MCP=0

for a in "$@"; do
  case "$a" in
    --dry-run) DRY=1 ;;
    --update)  DO_UPDATE=1 ;;
    --no-mcp)  NO_MCP=1 ;;
    -h|--help) sed -n '2,15p' "$0"; exit 0 ;;
    *) echo "Unknown flag: $a (see --help)"; exit 2 ;;
  esac
done

C_B="\033[1;36m"; C_G="\033[32m"; C_Y="\033[33m"; C_R="\033[31m"; C_0="\033[0m"
step(){ printf "\n${C_B}== %s${C_0}\n" "$*"; }
ok(){   printf "  ${C_G}OK${C_0}  %s\n" "$*"; }
warn(){ printf "  ${C_Y}!!${C_0}  %s\n" "$*"; }
err(){  printf "  ${C_R}XX${C_0}  %s\n" "$*"; }
dryline(){ printf "  ${C_Y}[dry-run]${C_0} %s\n" "$*"; }

printf "${C_B}\nHermes Boost Pack${C_0} - %s\n" "$(date +%F)"

# --- 0. preflight -----------------------------------------------------------
step "0/4 Preflight"
if ! command -v hermes >/dev/null 2>&1; then
  err "hermes not found on PATH. Install it first:"
  echo "    https://hermes-agent.nousresearch.com/docs"
  exit 1
fi
ok "hermes found: $(hermes --version 2>/dev/null | head -1)"
if [ "$DO_UPDATE" = 1 ]; then
  echo "  updating Hermes itself..."
  if [ "$DRY" = 1 ]; then dryline "hermes update -y"; else hermes update -y || warn "hermes update reported an issue (continuing)"; fi
else
  hermes update --check 2>/dev/null | tail -2 || true
  echo "  (tip: pass --update to update Hermes itself, or run 'hermes update' later)"
fi

# --- 1. capabilities --------------------------------------------------------
step "1/4 Capabilities - vision, video, voice, desktop control"
if [ "$DRY" = 1 ]; then
  dryline "hermes tools enable --platform <each of: $PLATFORMS> $TOOLSETS"
else
  FAILED=""
  for p in $PLATFORMS; do
    hermes tools enable --platform "$p" $TOOLSETS >/dev/null 2>&1 || FAILED="$FAILED $p"
  done
  if [ -z "$FAILED" ]; then
    ok "enabled: $TOOLSETS"
    ok "on platforms: cli, telegram, discord, slack, whatsapp, signal, matrix, email, sms"
  else
    warn "could not enable on:$FAILED - run 'hermes tools' to toggle manually"
  fi
fi
echo "  - vision: look at images/screenshots  - video: analyse videos by URL/file"
echo "  - stt: transcribe voice notes         - computer_use: drive the desktop"
echo "  - video_gen: generate videos (needs a backend key - see the end)"

# --- 2. skills from the boost tap -------------------------------------------
step "2/4 Skills from the boost tap"
if hermes skills tap list 2>/dev/null | grep -q "$REPO"; then
  ok "tap already added: $REPO"
elif [ "$DRY" = 1 ]; then
  dryline "hermes skills tap add $REPO"
elif hermes skills tap add "$REPO"; then
  ok "tap added: $REPO"
else
  warn "tap add failed (skills can still be installed one by one)"
fi

HH="${HERMES_HOME:-$HOME/.hermes}"
for s in $SKILLS; do
  if [ -d "$HH/skills" ] && [ -n "$(find "$HH/skills" -maxdepth 4 -type d -name "$s" 2>/dev/null | head -1)" ]; then
    ok "skill already installed: $s"
  elif [ "$DRY" = 1 ]; then
    dryline "hermes skills install $REPO/skills/$s --yes --category boost"
  else
    OUT="$(hermes skills install "$REPO/skills/$s" --yes --category boost 2>&1)"
    if [ -n "$(find "$HH/skills" -maxdepth 4 -type d -name "$s" 2>/dev/null | head -1)" ]; then
      ok "installed skill: $s"
    else
      printf '%s\n' "$OUT" | tail -6
      warn "could not install skill: $s (run: hermes skills install $REPO/skills/$s)"
    fi
  fi
done

# --- 3. Playwright MCP (optional) -------------------------------------------
step "3/4 Browser superpowers (Playwright MCP server)"
if [ "$NO_MCP" = 1 ]; then
  warn "skipped (--no-mcp)"
elif ! command -v npx >/dev/null 2>&1; then
  warn "npx (Node.js) not found - install Node.js then re-run; skipping"
elif [ "$DRY" = 1 ]; then
  dryline "hermes mcp add playwright --command npx --connect-timeout 60 --args -y @playwright/mcp@latest"
else
  PWS="$(hermes mcp list 2>/dev/null | grep playwright || true)"
  if printf '%s' "$PWS" | grep -q "disabled"; then
    hermes mcp remove playwright >/dev/null 2>&1 || true
    PWS=""
  fi
  if [ -z "$PWS" ]; then
    echo "  warming up the Playwright package (first run downloads it)..."
    npx -y @playwright/mcp@latest --help >/dev/null 2>&1 </dev/null || true
    printf 'y\n' | hermes mcp add playwright --command npx --connect-timeout 60 --args -y @playwright/mcp@latest >/dev/null 2>&1 || true
    PWS="$(hermes mcp list 2>/dev/null | grep playwright || true)"
  fi
  if [ -n "$PWS" ] && ! printf '%s' "$PWS" | grep -q "disabled"; then
    ok "playwright MCP ready (~25 browser tools; test: hermes mcp test playwright)"
  else
    warn "playwright MCP not ready yet. Retry later with:"
    echo "      hermes mcp add playwright --command npx --connect-timeout 60 --args -y @playwright/mcp@latest"
  fi
fi

# --- 4. capability check + doctor -------------------------------------------
step "4/4 Capability check"
T="$(hermes tools list 2>/dev/null || true)"
for t in web browser vision image_gen video; do
  if echo "$T" | grep -qE "enabled +$t"; then
    ok "$t enabled"
  else
    warn "$t not enabled - run 'hermes tools' (or 'hermes setup --portal')"
  fi
done
if [ "$DRY" = 0 ]; then
  echo "  running hermes doctor..."
  hermes doctor 2>&1 | tail -12 || warn "doctor reported issues (see output above)"
fi

printf "\n${C_G}Boost complete.${C_0}\n"
cat <<'EOF'

Next steps
  - Start a NEW session so tools + skills load (in chat: /new, or restart the
    gateway / desktop app).
  - Test vision: attach a picture and ask "what do you see?"
  - Test video: ask "analyse this video: <url or file>"
  - See the new skills: hermes skills list   (in chat: /skills)
  - Update later: re-run this script. It is idempotent.

Optional power-ups (each unlocks one extra capability)
  - One login for web + images + voice + browser:   hermes setup --portal
  - Video generation:  a backend key - XAI_API_KEY (or Grok login), FAL_KEY,
                       OPENROUTER_API_KEY, or DEEPINFRA_API_KEY
  - Voice input (stt): pip install faster-whisper   (free, local)
                       or set GROQ_API_KEY (free tier)
  - Desktop control:   hermes tools -> Computer Use -> install cua-driver
                       (grant Accessibility + Screen Recording on macOS)
  - X/Twitter search:  xAI credentials (hermes auth)

Undo (any step)
  hermes tools disable vision video stt video_gen computer_use
  hermes skills uninstall <name>
  hermes mcp remove playwright
  hermes skills tap remove El-Kurdi-Chad/hermes-boost
EOF
