# rustport — Claude Code skill for porting games & apps to Rust (+ wgpu)

An agent skill that drives a disciplined porting workflow: survey → plan → golden tests recorded from the
original → headless core port → winit/wgpu rendering → measured parity.

## Install
```bash
./install.sh            # -> ~/.claude/skills/rustport
./install.sh --project  # -> ./.claude/skills/rustport
```

## Use
In Claude Code: *"Port ~/games/snake (C++/SDL2/OpenGL) to Rust with wgpu"* — the skill triggers automatically.

## Contents
| Path | Purpose |
|---|---|
| `SKILL.md` | the workflow the agent follows |
| `scripts/survey.sh` | inventory of a source tree (langs, engine/graphics hints, assets, risk hotspots) |
| `scripts/scaffold.sh` | Cargo workspace: `<name>-core` (headless logic) + `<name>` (winit+wgpu app or plain bin) |
| `scripts/parity.sh` | golden vs port comparison with numeric tolerance (text/JSON/CSV, PNG) |
| `assets/wgpu_template/` | minimal winit 0.30 + wgpu 30 app (compiles; update when wgpu bumps) |
| `assets/mappings.md` | idiom map, C++/C#/Python → Rust crate map, wgpu gotchas, "do I need wgpu?" table |
| `assets/PORT_TEMPLATE.md` | living port plan copied to `docs/PORT.md` |

## No source code?
For closed binaries/APK/Electron the skill uses [REA](https://rea.tools) ([repo](https://github.com/morluto/rea)) (`npx rea-agents@latest setup`) to recover behavior and record golden data. See `assets/rea.md`.

## Maintenance
wgpu's API changes every release. After bumping, run `scripts/scaffold.sh t /tmp/t` and fix `assets/wgpu_template` until `cargo check` is green.
