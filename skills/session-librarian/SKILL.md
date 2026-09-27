---
name: session-librarian
description: "Organize sessions by prompt: find, rename, archive, prune."
version: 1.0.0
author: Hermes Agent + Teknium
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [Sessions, Organization, Cleanup, Library, Productivity]
    category: productivity
    related_skills: [weekly-review-planning]
---

# Session Librarian

Manage the user's session library conversationally: find past sessions about a
topic, summarize what they decided, rename them meaningfully, split work into
parallel sessions, and propose stale ones for archive or deletion — all from a
plain-language request like *"find my sessions about Q3 pricing, keep the
useful ones, and clean up the duplicates."*

Inspired by Perplexity Computer's prompt-driven session management (Aug 2026):
the agent starts, organizes, and cleans up the user's own session library, and
always shows the plan before touching anything.

## When to Use

- "What sessions do I have about X?" / "What did we decide about X?"
- "Rename these sessions to something meaningful."
- "Clean up my session library" / "archive the stale ones."
- "Fork that session into a follow-up focused on Y."
- "Split this into one session per ticket" (see Parallel workstreams below).

## The Two Surfaces

| Task | Surface |
|---|---|
| Find sessions by topic, read content, summarize decisions | `session_search` tool (FTS5 over the message store) |
| List/filter by metadata (age, source, cost, tokens, workspace) | `hermes sessions list` / `stats` via terminal |
| Rename | `hermes sessions rename <session_id> <title...>` |
| Bulk soft-hide (reversible) | `hermes sessions archive <filters>` |
| Delete (destructive) | `hermes sessions delete` / `hermes sessions prune <filters>` |
| Export before deleting anything valuable | `hermes sessions export --session-id <id> --format md` |
| Continue work in a new place | `/branch` (fork current session) or start a fresh session and cite the summary |

## Procedure

① **Discover.** Use `session_search(query=..., limit=5-10)` with topic
keywords; vary phrasing (feature name, symptom, project name). For metadata
sweeps ("sessions older than 60 days from telegram"), use
`hermes sessions list --source telegram --limit 50` instead.

② **Summarize per session.** The discovery result's `bookend_start` (goal),
match window, and `bookend_end` (resolution) usually suffice — only dump a
full session (`session_search(session_id=...)`) when the user asks for
decisions in depth. Report each as: link (`@session:` form) — one-line goal —
one-line outcome.

③ **Plan before acting (MANDATORY for anything that mutates).** Present a
plan table first: which sessions get renamed to what, which get archived,
which are proposed for deletion and why (duplicate of which keeper, stale,
empty). Wait for the user's go-ahead. Exception: a single rename the user
explicitly dictated can be done directly.

④ **Act with the safest primitive.**
- Prefer `archive` (reversible soft-hide) over `delete`/`prune`.
- Always run destructive commands with `--dry-run` first and show the output,
  then re-run with `--yes` after confirmation.
- Before deleting anything with meaningful content, offer
  `hermes sessions export --format md` as a backup.

⑤ **Report.** Renames applied, sessions archived (count + how to undo:
archived sessions remain in the DB and are listed with `--include-archived`),
anything exported, anything skipped and why.

## Parallel Workstreams

For "one session per ticket, investigate each, report back": do NOT try to
drive other live sessions. Use `delegate_task` with one task per workstream —
each subagent runs in its own session automatically — then synthesize their
summaries. Mention that each delegation's transcript is itself searchable
later via `session_search`.

## Bulk "Move to project" (desktop Projects)

The desktop sidebar groups sessions by **Projects** (named workspaces, per-profile
`projects.db`, ids `p_<hex>`). "Move to project" = re-home a session: its `cwd`
(+ git branch/root) is REPLACED with the project's root folder; the sidebar tree
then claims it (membership = session `cwd` OR git repo root sits under any of
the project's folders; sessions with empty cwd are unclaimable → "Home").

The UI moves one session at a time. To bulk-move N sessions, replicate what the
gateway's `session.workspace.move` RPC does for stored sessions (`tui_gateway/methods_session.py`):

1. `hermes project create "<Name>" <folder>` — first folder = primary (= where moved
   sessions land). Check: `hermes project list` / `show <slug>`.
2. Pick sessions (content match works: `SELECT id FROM sessions WHERE id IN (SELECT
   DISTINCT session_id FROM messages WHERE content LIKE '%<kw>%')`).
3. Backup first (id → old cwd/git_branch/git_repo_root) to a durable path.
4. Re-home each, using the repo venv Python (same code the desktop uses):
   ```python
   from hermes_state import SessionDB
   from tui_gateway import git_probe
   db = SessionDB(db_path=Path.home() / '.hermes' / 'state.db')
   t = '<project folder>'
   db.update_session_cwd(sid, t, git_probe.branch(t), git_probe.common_repo_root(t), replace_git_meta=True)
   ```
5. Verify with the app's OWN builder — `tui_gateway.project_tree.build_tree(
   [{'id': pid, 'label': name, 'folders': [{'path': t}]}], session_rows, [],
   resolve=git_probe.resolve, is_junk_root=lambda p: False, is_junk_cwd=lambda p: False,
   exists=os.path.isdir)` → the project node's `sessionCount` must equal N (also
   cross-check `_FolderIndex` + `_project_for_session` per moved id).

Pitfalls learned doing a large re-home (76 sessions):
- Cron sessions live in their OWN sidebar section — moving them is pointless.
- The running app shows the new grouping on its next tree fetch; if the sidebar
  looks stale, reload the window (Cmd+R) — don't re-run the move.
- Live sessions are safe to re-home via DB (live cache refreshes on reload); the
  official RPC additionally re-anchors the in-memory agent mid-turn.
- Word-match collections catch strays (personal errands, tooling/maintenance convs) —
  eyeball titles and drop the obvious ones; keep the skipped list for the report.

## Pitfalls

- **Never delete without a dry-run + explicit confirmation in this
  conversation.** A standing "clean things up" is authority to *propose*, not
  to prune.
- **`session_search` finds content, not metadata.** Age/cost/source filters
  live in the CLI; combine both when the request mixes them ("old sessions
  about pricing").
- **Titles are identity for `/resume <title>`.** When renaming, keep titles
  short, unique, and prefix-friendly; warn the user if a rename collides with
  an existing title.
- **Archived ≠ deleted.** Archive hides sessions from default listings only.
  Say which one you did.
- **Cross-profile session links** (`@session:<profile>/<id>`) are read-only
  from another profile; management commands act on the current profile's DB.

## Verification

After a cleanup pass, re-run the discovery query and `hermes sessions list`
to confirm the library reflects the plan (keepers present with new titles,
archived ones gone from the default listing).
