# Hermes Boost Pack

A small, safe, one-shot upgrade kit for an existing
[Hermes Agent](https://hermes-agent.nousresearch.com/docs) install.

**Additive & idempotent** — nothing is removed or overwritten, and re-running
is safe. The script is short and plain: read it before running it.

## What it does

| Step | Effect |
|---|---|
| 👁️ Vision | Enables the `vision` toolset → Hermes can look at images/screenshots instead of asking you to describe them |
| 📚 Skills | Installs 5 curated skills (boost/onboarding, skill-installing, self-maintenance, session librarian, deep research) from the `El-Kurdi-Chad/hermes-boost` tap |
| 🌐 Browser | Wires the Playwright MCP server (needs Node.js) so browser work is scriptable |
| 🩺 Check | Runs a capability check + `hermes doctor` and tells you what is still missing |

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
Hermes itself first) · `--no-mcp` (skip the Playwright server).

## Or let your Hermes do it

Paste this to your Hermes:

> Go to https://github.com/El-Kurdi-Chad/hermes-boost — read the README and the
> boost script, then boost yourself with it (install the skills, enable vision,
> add the Playwright MCP). Report what changed.

## What you get afterwards

- **Ask it anything.** It can now install more skills (`hermes skills search`),
  plugins (`hermes plugins browse`), MCP servers, cron automations. See the
  installed `hermes-boost` skill for the growth paths.
- **The magic prompt** — paste this in a new chat, one topic at a time:

  > "Looking at all the work and tasks I've given you about **<topic>** — what
  > can we automate? Posting, creating content, research, scheduling, whatever
  > you think makes sense — and what would the setup look like?"

- **One-login tool access** (no separate API keys): `hermes setup --portal`.

## Requirements

- A working Hermes install (`hermes --version` should work)
- Optional: Node.js / `npx` for the Playwright MCP server
- Skills install through the standard scan; each install shows its source and
  trust level (`hermes skills list`).

## Updates & undo

Re-run the script to pick up pack updates (idempotent). To undo any part:

```bash
hermes tools disable vision
hermes skills uninstall <name>
hermes mcp remove playwright
hermes skills tap remove El-Kurdi-Chad/hermes-boost
```

## Security

- No secrets, tokens or personal data are involved — the script only calls
  public `hermes` CLI commands.
- Third-party code runs with agent permissions; that's why the pack is small,
  auditable, and why each skill still passes Hermes' own scan on install.

MIT — built by Chad, shared with friends.
