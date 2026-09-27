# Roster UI metadata — `ui_meta.hermes-bots`

`<profile>/profile.yaml` drives the bot's card in the desktop Bot Mode roster.

## Fields (under `ui_meta.hermes-bots`)
| Field | Meaning | Notes |
|---|---|---|
| `title` | Display name | Short: `TypeSafe`, `Secu`, `Treso` |
| `shape` | Avatar shape | Every deployed bot uses `squircle` |
| `color` | Accent color | Quoted hex in YAML (`color: '#5B8DEF'`); pick one distinct from the others |
| `group` | Roster section | Free-form string; reuse an existing group when the bot belongs to one (`MufasaX`, `MufasaX Ops`, `Tools` are in use) |
| `created` | Epoch milliseconds | `python3 -c 'import time; print(int(time.time()*1000))'` |
| `chat` | Legacy session pin | Ignored and dropped by current builds — do NOT set; the canonical Bot Chat is resolved by session title, never by a stored id |

## Adjacent profile-level fields
- `description` — the kanban decomposer routes tasks by role using this. Set at create (`--description`) or later with `hermes profile describe <name> "<text>"`.
- `description_auto: false` — keeps the description under manual control.

## App-managed keys — leave alone
`hermes-bots-groups` and `ui_meta_revisions` implement bounded group-chat sync; the desktop app owns them.

## Verify after editing
```bash
python3 -c "import yaml,sys; d=yaml.safe_load(open(sys.argv[1])); print(d['ui_meta']['hermes-bots'])" ~/.hermes/profiles/<name>/profile.yaml
```
