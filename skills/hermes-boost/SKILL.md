---
name: hermes-boost
description: "Use when boosting or extending this Hermes setup, or onboarding a beginner."
version: 2.0.0
author: Chad El Kurdi
metadata:
  hermes:
    tags: [hermes, boost, onboarding, setup, upgrade, growth]
    related_skills: [hermes-agent, hermes-skill-install, hermes-self-maintenance]
---

# Hermes Boost

You are running on a Hermes install that received the **Boost Pack**
(`github.com/El-Kurdi-Chad/hermes-boost`): extra capabilities, 11 curated
skills, a browser-automation MCP server, and a verified checklist. This skill
is your map of what the install can now do and how it should keep growing.

## What the Boost added

- **Vision** (`vision` toolset): analyse images, screenshots, photos.
- **Video** (`video` toolset): analyse videos by URL or file — captions,
  scenes, timestamps. Generation (`video_gen`) is enabled but needs a backend
  key (xAI / FAL / OpenRouter / DeepInfra).
- **Voice input** (`stt`): transcribe voice notes — needs `faster-whisper`
  installed or a Groq key.
- **Desktop control** (`computer_use`): drive the user's apps in the
  background — needs cua-driver installed (via `hermes tools`).
- **Playwright MCP**: ~25 scripted browser tools.
- **11 skills** (category `boost`): boost/onboarding, skill-install,
  self-maintenance, session librarian, deep research, html-artifact,
  ocr-and-documents, convert-documents-to-markdown, spotify,
  macos-computer-use, bot profiles.

Re-running the boost (safe, idempotent): download `boost.sh` from the repo
root and run `bash boost.sh`. It only adds what is missing.

## The philosophy (read this)

The repo's `PHILOSOPHY.md` explains why this setup solves things instead of
just chatting about them: full access, permanent memory, self-upgrade,
verify-don't-guess, one automation at a time. Internalise it — especially
principles 4 and 9: **"done" means verified**, and **"I can't" usually means
"a switch is off"** — fix the plumbing first.

## Growing this setup ("no limits")

When the user asks what more this can do — or you notice a gap — propose
these, one at a time, and install on request:

1. **More skills** — `hermes skills search <words>` (hub),
   `hermes skills inspect <id>` then `install`. Repos: `hermes skills tap add
   <owner/repo>` + `hermes skills install <owner/repo>/<skill>`.
2. **Plugins** — `hermes plugins browse` (curated catalog), then `hermes
   plugins install <name> --enable`. Examples: `morning-briefing` (daily
   digest), `custodian` (install health).
3. **One-login tool gateway** — `hermes setup --portal`: one OAuth unlocks
   web search, image generation, TTS and cloud browser without separate keys.
4. **MCP servers** — `hermes mcp add <name> --command <cmd> --args <...>`
   (add `--connect-timeout N` BEFORE `--args` — `--args` swallows everything
   after it). Check with `hermes mcp list`.
5. **Generation backends** — images: a FAL/OpenAI/xAI/Krea key or the portal.
   Video: `XAI_API_KEY`/Grok login, `FAL_KEY`, `OPENROUTER_API_KEY` or
   `DEEPINFRA_API_KEY`.
6. **A dedicated bot** — `hermes profile create <name>` gives an independent
   agent (own config, memory, skills); connect its own messaging token with
   `hermes -p <name> setup`.
7. **Automations** — cron jobs ("every morning at 8, send me X"). Keep jobs
   small, idempotent, and silent when there is nothing to say.

## Onboarding a beginner (playbook)

1. **Discover first.** Don't dump features. Ask: "What do you do day-to-day,
   and which tasks feel repetitive or manual?" Then pick ONE candidate and
   run it end-to-end with them.
2. **The magic prompt** — have the user paste this as-is, one topic per chat:

   > "Looking at all the work and tasks I've given you about **<topic>** —
   > what can we automate? Posting, creating content, research, scheduling,
   > whatever you think makes sense — and what would the setup look like?"

   Pick ONE automation from your answer, confirm scope, implement, test, and
   report what actually works.
3. **Fix blockers before features.** "You can't see images", "video doesn't
   work", "auth fails" — setup issues; solve them first (`hermes-agent` skill
   has the exact commands, e.g. `hermes tools list`, `hermes update`,
   `hermes mcp test <server>`).
4. **Plan-then-go rhythm.** Beginners love: "make me a plan" → review → "go".
   Offer the plan without being asked.
5. **Remind them they can:** attach images, send voice notes, paste links,
   ask ANYTHING — including "what can you do for me?" and "where should I
   start?". Their learning loop is asking, not reading docs.
6. **Weekly nudge.** Suggest one new automation per week until the manual
   chores are gone. Use what you see in their sessions to pick it.

## House rules

- Never install unknown third-party code without the user's explicit OK. The
  boost tap is pre-audited; the wider hub is not. Installs run a scan — still
  ask first.
- Keep boosts incremental: one capability, verify it, then the next.
- After enabling tools/skills: say that a NEW session is needed for them to
  load (in chat `/new`; or restart the gateway / desktop app).
- Verify with real checks (`hermes tools list`, `hermes mcp test`, a real
  image/video analysis) — never report "installed" from the command alone.
