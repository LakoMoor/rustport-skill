# Using REA (https://rea.tools) when the original has no source

REA lets an agent read decompiled code, instructions and call relationships of shipped software, observe it while
running, and check recovered rules against the original. Targets: native executables/libraries, JavaScript/Electron
apps, browsers/web apps, Android APKs (also managed .NET, firmware).

## Setup (needs user approval - it writes agent config)
```bash
npx -y rea-agents@latest doctor --json            # diagnose, read-only
npx -y rea-agents@latest setup --dry-run --json   # show the plan to the user
npx -y rea-agents@latest setup --yes              # only after approval; then restart the agent
```
Also load the `reverse-engineer-anything` skill; it routes by target type.

## Routing
| Target | Start with |
|---|---|
| ASAR / JS tree | `analyze_javascript_application` |
| APK | `inspect_android_package` |
| native exe/lib/.app | `open_binary` -> `binary_overview`, `search_procedures`, `procedure_pseudo_code`, `get_call_graph` |
| .NET assembly | `inspect_managed_artifact` |
| open browser / Electron | `list_browser_targets` / `list_electron_targets`, then `capture_*_scenario` |

## Porting workflow with REA
1. **Inventory**: strings, resources, exported/entry functions, imports (graphics API, audio, network) -> fills the survey.
2. **Feature trace**: `trace_feature` / `trace_application_feature` from a seed (a string, an input handler) to the rules it implements.
3. **Rule recovery**: write each recovered rule as a short spec in `docs/PORT.md` (inputs, formula, constants, edge cases) with Evidence IDs.
4. **Golden data**: capture scenarios from the *running* original (`capture_process_scenario`, `capture_browser_scenario`, screenshots) -> `tests/golden/`. Static analysis alone is not a golden.
5. **Verify**: compare the Rust port against the captured scenarios with `scripts/parity.sh`; use `compare_*` tools to diff original versions if the target updates.

## Rules
- Separate observed / inferred / unknown. Never claim execution behavior from static analysis.
- Version-pin: record hash, version, platform of the inspected build.
- Reconstruct, don't copy: reimplement logic in idiomatic Rust; recovered constants and rules are fine, decompiler output is not a deliverable.
- Respect licenses and law; only analyze what you're permitted to. Leave user data untouched when running the original.
