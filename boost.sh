#!/usr/bin/env bash
# ============================================================================
#  Hermes Boost Pack - https://github.com/El-Kurdi-Chad/hermes-boost
#  Adds a curated upgrade kit to an existing Hermes Agent install.
#  Additive & idempotent: nothing is removed, safe to re-run.
#
#  Usage:  bash boost.sh [--dry-run] [--update] [--no-mcp]
#    --dry-run   show what would happen, change nothing
#    --update    also update Hermes itself first (hermes update -y)
#    --no-mcp    skip the optional Playwright MCP server
#
#  Read this file before piping it into bash - it is short and plain.
# ============================================================================
set -u
REPO="El-Kurdi-Chad/hermes-boost"
SKILLS="hermes-boost hermes-skill-install hermes-self-maintenance session-librarian deep-research"
DRY=0; DO_UPDATE=0; NO_MCP=0

for a in "$@"; do
  case "$a" in
    --dry-run) DRY=1 ;;
    --update)  DO_UPDATE=1 ;;
    --no-mcp)  NO_MCP=1 ;;
    -h|--help) sed -n '2,14p' "$0"; exit 0 ;;
    *) echo "Unknown flag: $a (see --help)"; exit 2 ;;
  esac
done

C_B="\033[1;36m"; C_G="\033[32m"; C_Y="\033[33m"; C_R="\033[31m"; C_0="\033[0m"
step(){ printf "\n${C_B}== %s${C_0}\n" "$*"; }
ok(){   printf "  ${C_G}OK${C_0}  %s\n" "$*"; }
warn(){ printf "  ${C_Y}!!${C_0}  %s\n" "$*"; }
err(){  printf "  ${C_R}XX${C_0}  %s\n" "$*"; }
run(){  if [ "$DRY" = 1 ]; then printf "  ${C_Y}[dry-run]${C_0} %s\n" "$*"; else "$@"; fi; }

printf "${C_B}\nHermes Boost Pack${C_0} - %s\n" "$(date +%F)"

# --- 0. preflight -----------------------------------------------------------
step "0/4 Preflight"
if ! command -v hermes >/dev/null 2>&1; then
  err "hermes not found on PATH. Install it first:"
  echo "    curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash"
  exit 1
fi
ok "hermes found: $(hermes --version 2>/dev/null | head -1)"
if [ "$DO_UPDATE" = 1 ]; then
  echo "  updating Hermes itself..."
  run hermes update -y || warn "hermes update reported an issue (continuing)"
else
  hermes update --check 2>/dev/null | tail -2 || true
fi

# --- 1. vision toolset ------------------------------------------------------
step "1/4 Vision - let Hermes look at images"
if hermes tools list 2>/dev/null | grep -qE "enabled +vision"; then
  ok "vision toolset already enabled"
else
  if run hermes tools enable vision; then
    ok "vision enabled - Hermes can now analyse images/pictures/screenshots"
  else
    warn "could not enable vision automatically - run 'hermes tools' and enable it"
  fi
fi
echo "  note: on a text-only main model, images are analysed by an auxiliary"
echo "        vision model - if that is not configured yet, see 'hermes-agent'"
echo "        skill / 'hermes setup --portal'."

# --- 2. skills from the boost tap -------------------------------------------
step "2/4 Skills from the boost tap"
if hermes skills tap list 2>/dev/null | grep -q "$REPO"; then
  ok "tap already added: $REPO"
else
  run hermes skills tap add "$REPO" || warn "tap add failed (skills can still be installed one by one)"
fi

HH="${HERMES_HOME:-$HOME/.hermes}"
for s in $SKILLS; do
  if [ -d "$HH/skills" ] && [ -n "$(find "$HH/skills" -maxdepth 4 -type d -name "$s" 2>/dev/null | head -1)" ]; then
    ok "skill already installed: $s"
  else
    if run hermes skills install "$REPO/skills/$s" --yes --category boost; then
      ok "installed skill: $s"
    else
      warn "could not install skill: $s (see: hermes skills list)"
    fi
  fi
done

# --- 3. Playwright MCP (optional) -------------------------------------------
step "3/4 Browser superpowers (Playwright MCP server)"
if [ "$NO_MCP" = 1 ]; then
  warn "skipped (--no-mcp)"
elif hermes mcp list 2>/dev/null | grep -q "playwright"; then
  ok "playwright MCP already configured"
elif ! command -v npx >/dev/null 2>&1; then
  warn "npx (Node.js) not found - install Node.js then re-run this script"
else
  if run hermes mcp add playwright --command npx --args "@playwright/mcp@latest" --connect-timeout 30; then
    ok "playwright MCP added"
  else
    warn "playwright MCP setup failed (see: hermes mcp list)"
  fi
fi

# --- 4. capability check + doctor -------------------------------------------
step "4/4 Capability check"
T="$(hermes tools list 2>/dev/null || true)"
for t in web browser vision image_gen; do
  if echo "$T" | grep -qE "enabled +$t"; then
    ok "$t enabled"
  else
    warn "$t not enabled - run 'hermes setup --portal' (one login unlocks web + images + browser) or 'hermes tools'"
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
  - See the new skills: hermes skills list   (in chat: /skills)
  - Update later: re-run this script. It is idempotent.
  - Questions? Ask your Hermes: "what can you do for me now?"

Undo (any step)
  hermes tools disable vision
  hermes skills uninstall <name>
  hermes mcp remove playwright
  hermes skills tap remove El-Kurdi-Chad/hermes-boost
EOF
