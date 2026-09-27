---
name: hermes-boost
description: "Use when boosting or extending this Hermes setup, or onboarding a beginner."
version: 1.0.0
author: Chad El Kurdi
metadata:
  hermes:
    tags: [hermes, boost, onboarding, setup, upgrade]
    related_skills: [hermes-agent, hermes-skill-install, hermes-self-maintenance]
---

# Hermes Boost

You are running on a Hermes install that received the **Boost Pack**
(`github.com/El-Kurdi-Chad/hermes-boost`). This skill is your map of the
upgrade paths, and the playbook for onboarding a beginner user.

## The boost pack

One-shot installer — additive and idempotent, safe to re-run:

```bash
curl -fsSL https://raw.githubusercontent.com/El-Kurdi-Chad/hermes-boost/main/boost.sh | bash
```

It (1) enables the vision toolset, (2) installs the boost skills from the
`El-Kurdi-Chad/hermes-boost` tap, (3) wires the Playwright MCP server when
Node.js is present, (4) reports missing capabilities. Flags: `--dry-run`,
`--update`, `--no-mcp`.

## Growing this setup ("no limits")

When the user asks what more Hermes can do — or you notice a capability gap —
propose these, one at a time, and install on request:

1. **More skills** — `hermes skills search <words>` (hub), `hermes skills
   inspect <id>` then `install`. Repos work too: `hermes skills tap add
   <owner/repo>` + `hermes skills install <owner/repo>/<skill>`.
2. **Plugins** — `hermes plugins browse` (curated catalog), then `hermes
   plugins install <name> --enable` (e.g. `morning-briefing` for a daily
   digest). Plugins are opt-in and capability-gated; ask before enabling.
3. **One-login tool gateway** — `hermes setup --portal`: one OAuth unlocks
   web search, image generation, TTS and cloud browser without separate keys.
4. **MCP servers** — `hermes mcp add <name> --command <cmd> --args <...>` or
   `--url <endpoint>`; discover with `hermes mcp list`.
5. **A dedicated bot** — `hermes profile create <name>` gives an independent
   agent (own config, memory, skills); connect its own messaging token with
   `hermes -p <name> setup`.
6. **Automations** — cron jobs ("every morning at 8, send me X"). Keep jobs
   small, idempotent, silent when there is nothing to say.

## Onboarding a beginner (playbook)

1. **Discover first.** Don't dump features. Ask: "What do you do day-to-day,
   and which tasks feel repetitive or manual?" Then pick ONE candidate and run
   it end-to-end with them.
2. **The magic prompt** — have the user paste this as-is, one topic per chat:

   > "Looking at all the work and tasks I've given you about **<topic>** —
   > what can we automate? Posting, creating content, research, scheduling,
   > whatever you think makes sense — and what would the setup look like?"

   Pick ONE automation from your answer, confirm scope, implement, test, and
   report what actually works.
3. **Fix blockers before features.** "You can't see images", "it's too slow",
   "auth fails" — these are setup issues; solve them first (see the
   `hermes-agent` skill for exact commands, e.g. `hermes tools enable vision`,
   `hermes update`).
4. **Plan-then-go rhythm.** Beginners love: "make me a plan" → review → "go".
   Offer the plan without being asked.
5. **Remind them they can:** attach images, send voice notes, ask ANYTHING —
   including "what can you do for me?" and "where should I start?". Their
   learning loop is asking, not reading docs.
6. **Weekly nudge.** Suggest one new automation per week until the manual
   chores are gone. Support it with what you see in their sessions.

## House rules

- Never install unknown third-party code without the user's explicit OK. The
  boost tap is pre-audited; the wider hub is not. Installs run a scan — still
  ask first.
- Keep boosts incremental: one capability, verify it, then the next.
- After enabling tools/skills: say that a NEW session is needed for them to
  load (in chat `/new`; or restart the gateway / desktop app).
