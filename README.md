# rustport

Port games and apps to Rust, including compatible game runtimes that load the
original maps, assets, scripts and saves. Capture the original's behavior, port a
small playable slice, then measure compatibility as the project grows.

One Agent Skills bundle for **Codex, Claude Code, OpenCode, Pi, DeepSeek Harness
(DSH), and Hermes**. No model or MCP setup is changed by the installer.

## Install

Requires Python 3.9+. Clone first:

```sh
git clone https://github.com/LakoMoor/claude-rustport-skill.git
cd claude-rustport-skill
python3 install.py --agent all
```

Or choose agents and scope:

```sh
python3 install.py --agent codex --agent claude
python3 install.py --agent opencode --project
python3 install.py --agent pi --agent dsh --agent hermes --project
python3 install.py --agent all --dry-run
```

`./install.sh` remains a Bash entrypoint; without options it installs for Claude
Code, preserving the previous behavior. On Windows use `py -3 install.py` instead
of `python3`. The bundled shell helpers need Bash (Git Bash/WSL), Python 3 and
Cargo. GPU/platform support depends on the target and the wgpu toolchain.

Existing differing files are preserved unless you explicitly pass `--force`.
`--root PATH` selects a project root; `--home PATH` selects an alternate user home.
See [agent locations and environment overrides](references/agents.md).

## Invoke

| Agent | Explicit command |
|---|---|
| Codex | `/skills` → choose `rustport`, or `$rustport <request>` |
| Claude Code | `/rustport <request>` |
| OpenCode | `/rustport <request>` |
| Pi | `/rustport <request>`; also `/skill:rustport <request>` |
| DeepSeek Harness | `/rustport <request>` |
| Hermes | `/rustport <request>` |

OpenCode gets a command file; Pi gets a prompt template. Both load the same skill
bundle and pass your arguments. Other agents use native skill discovery. Codex
uses its native skill selector rather than an unsupported `/rustport` alias.
Reload/restart after installing if needed; Pi has `/reload`. Hermes project skills
require project trust (`hermes skills trust` after reviewing the bundle). DSH needs
its filesystem skill provider enabled. Host command/trust settings still apply.

Examples (use the invocation syntax for your agent):

```text
/rustport Port ~/games/snake from C++/SDL2 to Rust with wgpu
/rustport Reimplement this game's runtime in Rust, loading my original maps and scripts
/rustport Continue this port: fix save/load compatibility and compare with the original
```

## What the agent does

- **Source port:** survey → scope → original-side golden tests → Rust core → rendering → measured parity.
- **Compatible runtime:** pin the reference build, inspect real content, maintain a
  compatibility ledger, and bring up a playable slice through the real game loop.
- **Continued work:** resume the ledger, reproduce a behavior gap, repair the actual
  runtime path, and update evidence instead of restarting the project.

For Horizon/openOMSI-style work, the additional
[compatible-runtime workflow](references/compatible-runtime.md) covers original
formats and scripts, reference oracles, save/load, streaming, deterministic
scenarios, agent control, and progress across sessions. This is a development
workflow, not a promise that a complete game can be recreated in a single run.

## Bundle

| Path | Purpose |
|---|---|
| `SKILL.md` | Agent-neutral entrypoint and mode selection |
| `references/agents.md` | Agent discovery, commands and upstream documentation |
| `references/compatible-runtime.md` | Whole-game runtime reconstruction |
| `scripts/survey.sh` | Source inventory and risk hints |
| `scripts/scaffold.sh` | Headless core + Rust app workspace |
| `scripts/parity.sh` | Golden output comparisons |
| `assets/wgpu_template/` | winit 0.30 + wgpu 30 starter |
| `assets/mappings.md` | Language/library map and graphics notes |
| `assets/PORT_TEMPLATE.md` | Living port plan |

With only a shipped binary, APK or Electron app, use available reverse-engineering
and runtime-observation tools. [REA integration](assets/rea.md) is optional; the
skill must disclose unavailable tools and unverified behavior rather than invent
results. Original game content stays local to the user's installation.

## Validation and maintenance

```sh
python3 -m unittest discover -s tests -v
```

Installer tests use temporary homes/projects and do not start LLM sessions. Layout
and adapter tests do not prove interactive end-to-end behavior in all six clients.
After a wgpu update, generate a temporary workspace with `scripts/scaffold.sh` and
check it with Cargo on the intended platform before claiming the template builds.

## License

The rustport skill, installer, helpers, templates, documentation, and original
examples are licensed under [Apache-2.0](LICENSE), unless a file states otherwise.
Copyright 2026 LakoMoor and contributors.

The binary-derived openMMD example retains upstream MIT-covered material and its
[original copyright and license notice](examples/binary-name-slice/evidence/ORIGINAL-LICENSE).
Those upstream notices remain applicable; the repository license does not replace
third-party terms. See [NOTICE](NOTICE) for attribution. REA and the supported agent
clients are separate projects and are not bundled or relicensed here.

Using rustport does not automatically apply Apache-2.0 to a generated port, the
original program, or its assets. Choose the target project's license separately
and retain applicable original notices.
