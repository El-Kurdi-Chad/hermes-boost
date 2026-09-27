# Hermes Boost Pack

**Boost any Hermes install to its full potential — one command.**

A small, safe, idempotent upgrade kit for an existing
[Hermes Agent](https://hermes-agent.nousresearch.com/docs): extra
capabilities, curated skills, a browser-automation server — then a
verification pass that tells you exactly what's ready and what's missing.

Additive — nothing is removed or overwritten. Re-running is safe. The script
is short and plain: read it before running it.

## What you get

| Boost | Effect |
|---|---|
| 👁️ Vision | Hermes can look at images/screenshots instead of asking you to describe them |
| 🎬 Video | Analyse videos (URL or file): captions, scenes, key timestamps. Generation too — needs one backend key |
| 🎙️ Voice input | Voice notes get transcribed (`stt` enabled) |
| 🖱️ Desktop control | `computer_use` enabled — drive your apps in the background |
| 📚 Skills ×11 | Curated set, see below |
| 🌐 Playwright MCP | ~25 scriptable browser tools (needs Node.js) |
| 🩺 Verify | Capability check + `hermes doctor`, with the exact fix for anything missing |

## Quick start (one command)

```bash
curl -fsSL https://raw.githubusercontent.com/El-Kurdi-Chad/hermes-boost/main/boost.sh | bash
```

Prefer to look first (recommended):

```bash
curl -fsSL https://raw.githubusercontent.com/El-Kurdi-Chad/hermes-boost/main/boost.sh -o boost.sh
less boost.sh        # read it
bash boost.sh
```

Flags: `--dry-run` (change nothing, show the plan) · `--update` (also update
Hermes itself first — recommended if you're many versions behind) ·
`--no-mcp` (skip the Playwright server).

## Or let your Hermes do it

Paste this to your Hermes:

> Go to https://github.com/El-Kurdi-Chad/hermes-boost — read the README, the
> philosophy and the boost script, then boost yourself with it (capabilities,
> the 11 skills, the Playwright MCP). Report exactly what changed and verify
> each piece.

## The philosophy

Read [PHILOSOPHY.md](PHILOSOPHY.md) — the ten operating principles that make
this agent solve things instead of just chatting about them. The short
version: give it full access, let it remember and upgrade itself, expect
verified results, automate one chore at a time.

## Works for every kind of user

| You are… | Start with |
|---|---|
| **Creator / marketer** | The magic prompt (below), `html-artifact` for visual pages, image generation (portal), spotify/desktop skills |
| **Developer** | Everything: terminal, code execution, GitHub workflows, MCP servers, cron automations |
| **Student / researcher** | `deep-research`, `ocr-and-documents`, `convert-documents-to-markdown`, video analysis of lectures |
| **Ops / business** | Cron digests, reports, `session-librarian`, browser automation, scheduled monitoring |
| **Just personal life** | Voice notes, reminders, price watching, music, desktop control, "fix this for me" |

**The magic prompt** — paste in a new chat, one topic at a time:

> "Looking at all the work and tasks I've given you about **<topic>** — what
> can we automate? Posting, creating content, research, scheduling, whatever
> you think makes sense — and what would the setup look like?"

## The 11 skills

| Skill | Use |
|---|---|
| `hermes-boost` | Map of the boost + onboarding playbook + growth paths |
| `hermes-skill-install` | Install any skill safely (hub, repo, URL) |
| `hermes-self-maintenance` | Keep Hermes updated; watchdog patterns |
| `session-librarian` | Find / rename / clean up past sessions |
| `deep-research` | Multi-source cited investigations |
| `html-artifact` | Self-contained HTML pages to explain, plan, review |
| `ocr-and-documents` | Extract text from PDFs and scans |
| `convert-documents-to-markdown` | Word/PowerPoint/Excel/EPUB → Markdown |
| `spotify` | Play, queue, playlists (needs Spotify login) |
| `macos-computer-use` | Drive macOS apps in the background (macOS only) |
| `hermes-bot-profiles` | Create dedicated bot profiles (power user) |

## Optional power-ups (each unlocks one more thing)

- **One login for web + images + voice + browser:** `hermes setup --portal`
- **Video generation:** a backend key — `XAI_API_KEY` (or Grok login),
  `FAL_KEY`, `OPENROUTER_API_KEY`, or `DEEPINFRA_API_KEY`
- **Voice input:** `pip install faster-whisper` (free, local) or a Groq key
- **Desktop control:** `hermes tools` → Computer Use → install `cua-driver`
- **X/Twitter search:** xAI credentials

## Requirements

- A working Hermes install (`hermes --version` works)
- Optional: Node.js / `npx` for the Playwright MCP
- Skills install through Hermes' standard security scan; each install shows
  its source and trust level (`hermes skills list`)

## Updates & undo

Re-run the script to pick up pack updates (idempotent). Undo any part:

```bash
hermes tools disable vision video stt video_gen computer_use
hermes skills uninstall <name>
hermes mcp remove playwright
hermes skills tap remove El-Kurdi-Chad/hermes-boost
```

## Security

- No secrets, tokens or personal data — the script only calls public `hermes`
  CLI commands.
- Third-party code runs with agent permissions; that's why the pack is small,
  auditable, and every skill still passes Hermes' own scan on install.

MIT — built by Chad, shared with friends.
