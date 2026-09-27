---
name: hermes-bot-profiles
description: Create or maintain a Hermes bot profile (cree un agent).
---

# Hermes Bot Profiles (dedicated agents)

Workflow for the dedicated Hermes agent profiles — the "bots" of the desktop roster (hermes-bots pane), reachable through `~/.local/bin/<name>` aliases and routable via kanban. Modeled on the fleet already deployed (mx-*, qa-*, ops, typesafe).

## When to use
- "Cree un agent pour X" / "create a bot for X" / "new profile for Y".
- Maintaining an existing bot: skills curation, SOUL updates, roster card, description.
- NOT for ephemeral subtasks — those are `delegate_task`. Profiles are persistent identities: own config, `.env`, SOUL, sessions, skills.

## Key paths
- `~/.hermes/profiles/<name>/` — profile home (`config.yaml`, `.env`, `SOUL.md`, `skills/`, sessions, state).
- `~/.local/bin/<name>` — alias wrapper auto-created at create time (`hermes -p <name> "$@"`).
- `<profile>/profile.yaml` — `description` (routes kanban tasks) + `ui_meta.hermes-bots` (desktop roster card).
- `<profile>/skills/` — per-profile skills; not shared with the default profile.

## Procedure — new bot
1. **Secrets first.** Append the API key(s) the bot needs to the PARENT `~/.hermes/.env` BEFORE creating — `--clone` snapshots `.env`, so the clone only inherits keys already present.
2. **Its skill first, too.** A skill installed at the parent level before `--clone` is inherited by the profile; otherwise copy it into the profile afterwards. See the `hermes-skill-install` skill.
3. **Create:** `hermes profile create <name> --clone --description "<role, 1-2 sentences>"`.
   `--clone` copies config.yaml, .env, SOUL.md and skills from the active profile — messaging channels are deliberately NOT copied (two gateways would fight over one bot token). Variants: `--clone-all`, `--clone-from <src>`, `--clone-channels`, `--no-skills`, `--no-alias`.
4. **Curate skills.** The clone brings every category; keep the bot focused (`autonomous-ai-agents` + domain skills + a few shared symlinks is the house pattern). Move unwanted category dirs into `<profile>/_skills_unused/` (reversible) instead of `rm`.
5. **Stop bundled re-seeding BEFORE the first run:** `hermes -p <name> skills opt-out` (writes `<profile>/.no-bundled-skills`). Without it, the next session start re-creates empty `DESCRIPTION.md`-only shells for every bundled category you just removed.
6. **Fix relative skill symlinks.** Skills symlinked in from the parent (`<skill> -> ../../.agents/skills/<skill>`) dangle at the new depth. Re-point to `../../../../.agents/skills/<skill>` (count the levels from `~/.hermes/profiles/<name>/skills/`), then prove each resolves: `[ -e "<path>" ]`.
7. **Write the SOUL** (`<profile>/SOUL.md`), replacing the cloned generic one wholesale. House structure (French): `# <name> - <role>` / Mission / Methode (what makes its output trustworthy) / Acces (verified tools, exact commands, verification date) / Regles non negociables / Style (compact, phone-readable).
8. **Roster card** — `ui_meta.hermes-bots` in `<profile>/profile.yaml`; field table in `references/roster-ui-meta.md`. Minimum: `title`, `shape: squircle`, `color`, `group`, `created` (epoch ms).
9. **Smoke test end-to-end:** `<name> chat -q "<prompt exercising the bot's purpose>" -Q` and read the output — it must prove the wiring (e.g. a live API call returning HTTP 200, right model, right skill in play). One model call; always worth it.
10. **Verify:** `hermes profile show <name>` (model, alias, skills count) · `hermes -p <name> skills list` · `command -v <name>`.

## Delegating a task to a sibling bot (one-shot)

A dedicated profile is also a specialist worker / second opinion. Invoke it non-interactively; never
hand it a wall of inline prose.

1. **Dossier file, not a prompt.** Write the context to a durable directory
   (`~/.claude/<projet>/<chantier>/`, never `/tmp` — scratchpads get purged mid-work) and point the
   bot at it. It has read tools and re-reads the file; a long prompt does not survive compaction.
   No secret values in the dossier.
2. **One-shot call:** `~/.hermes/bin/hermes -p <name> -z "<short prompt pointing at the dossier>"`
   (the `~/.local/bin/<name>` alias wraps the same binary with `-p`). Foreground with a generous
   timeout — it returns as soon as it finishes.
3. **Ask for the deliverable AND its proof** in the prompt: a written file next to the dossier, the
   same content on stdout, plus a machine-checkable artifact for any external call (HTTP status, model
   name, raw response body). A bot whose SOUL demands proof-by-API will produce it — but only if you
   ask, and self-reported "I tested it" is not a proof.
4. **Scope the guardrails inside the prompt:** read-only, no production action, no secret read or
   write. A sibling bot has its own tools and its own idea of scope.
5. **Read the file yourself and relay it.** Your capture of its stdout can be truncated by your own
   `tail`, so treat the written file as the deliverable.

Pitfall: the bot knows nothing of the current conversation — everything it needs goes in the dossier.
A read-only analysis can be launched without a go; anything that mutates goes through the normal
propose/go gate.

## Pitfalls
- **Session start re-seeds category shells.** The bundled-skill sync recreates `DESCRIPTION.md` for any bundled category dir missing on disk — removed skills stay removed, but empty shells come back unless `.no-bundled-skills` is set (step 5). Do the opt-out before running any chat in the new profile.
- **Symlinks break by depth.** Relative targets were authored for `~/.hermes/skills/`; the profile path is deeper, so the same link string dangles silently. Recount `..` levels and verify with `[ -e ]`.
- **`.env` is a snapshot.** Keys added after the clone must be patched into both `~/.hermes/.env` AND `<profile>/.env`.
- **The "not in PATH" warning at create often lies** when the shell rc adds `~/.local/bin`. Check `command -v <name>` before "fixing" PATH.
- **Don't restart the gateway for a new bot.** The create output suggests `hermes gateway restart`; CLI + roster work without it. Messaging channels are set up only when the user asks, with the bot's OWN token (`hermes -p <name> setup`) — never clone channel tokens.
- **Roster group keys are app-managed.** `hermes-bots-groups` / `ui_meta_revisions` belong to the desktop app — don't hand-write them.
- **A running session won't see a newly added skill** (its skills prompt is frozen); a fresh run picks it up.

## References
- `references/roster-ui-meta.md` — ui_meta field table + roster conventions + verification snippet.
