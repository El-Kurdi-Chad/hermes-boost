---
name: hermes-skill-install
description: Install a skill into Hermes (hub, repo, or URL).
---

# Installing Skills into Hermes

Two install paths — the native hub and the external `skills` CLI — plus the audit-then-verify workflow. Third-party installs get vetted first: anything you install runs with full agent permissions, and the house leans supply-chain-cautious.

## When to use
- "Install the X skill", a vendor install prompt, or a repo/link for a skill.
- Use ONE installation method per agent — don't stack two installer flows for the same skill.

## Path A — native hub (tracked, scan-gated)
```bash
hermes skills inspect <identifier>    # preview without installing
hermes skills install <identifier>    # hub id, or a direct https://.../SKILL.md URL
# extras: --name <n> (frontmatter has no name), --category <dir>, --yes, --force (override a blocked scan verdict)
```
Maintenance: `hermes skills list` · `check` · `update` · `uninstall`. Hub installs show `Source: skills.sh`; the curator won't touch them.

## Path B — external repo via the vercel-labs `skills` CLI
```bash
npx --yes skills@latest add <owner>/<repo> --skill <name> --global --agent hermes-agent --yes
```
- Agent id is exactly `hermes-agent` (global target `~/.hermes/skills/`, honors `HERMES_HOME`); the CLI auto-detects installed agents, and `--agent` + `--yes` makes it fully non-interactive.
- Same CLI maintains it: `npx skills ls -g -a hermes-agent` (what's installed, where) · `npx skills update <name>` · `npx skills remove <name>`; `--list` previews a repo without installing.
- CLI-copied skills appear in `hermes skills list` as `Source: local` — normal, not an error.
- It prints a threat scan (Gen / Socket / Snyk) — a useful signal, not a substitute for the audit below.

## Audit-first (before any third-party install)
1. **Vet the source.** `npm view <pkg> --json` (maintainers, repo, weekly downloads) for the CLI; the GitHub repo API for the target (owner, description). Known orgs/maintainers beat anonymous repos.
2. **Read the payload before it lands.** `git clone --depth 1 <repo> /tmp/<audit>` and inspect the tree: expect `SKILL.md` + `LICENSE` (± plugin manifests). Any script, hook, or binary → read it or stop.
3. **Record the audited hash:** `shasum -a 256` of the repo's `SKILL.md`.
4. **Compare after install:** the installed `SKILL.md` must hash-match the audited one — byte-identical install is the point of the audit.
5. **Probe its live dependencies once** (e.g. a docs `llms.txt` URL should return 200) so the skill isn't pointing at a dead host.

## Post-install verification
- `hermes skills list | grep <name>` → `enabled`; sanity-check source/trust columns.
- `skill_view(name='<name>')` → must load immediately in the running session (the skills prompt snapshot only refreshes for NEW sessions).
- Skills are per-profile: a user-level install is NOT automatically visible to bot profiles. Stock a bot by copying the skill dir into `~/.hermes/profiles/<bot>/skills/`, or create the bot after installing.
