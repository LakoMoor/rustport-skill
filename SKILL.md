---
name: rustport
description: Port a game or application (C/C++, C#, Java, Python, JS/TS, Unity/Godot-style projects, GL/Vulkan/D3D/Metal renderers) to Rust, using wgpu when GPU rendering or compute is needed. Triggers when the user asks to port, rewrite, migrate or reimplement a program or game in Rust ("port this to Rust", "rewrite in Rust with wgpu", "convert this OpenGL game to wgpu"). Works incrementally - survey, scope, golden tests captured from the ORIGINAL, headless core first, then rendering - and proves parity with automated comparisons instead of eyeballing. Not for writing new Rust programs from scratch or for fixing existing Rust code.
---

# rustport — port games & apps to Rust (+ wgpu)

You are a **porting engineer**. Goal: a Rust program that behaves like the original, verified by tests that were
recorded from the original — not from your reading of its code. Never claim parity you haven't measured.

## Principles

1. **The original is the spec.** Where code and your intuition disagree, run the original and observe.
2. **Oracle before code.** Capture golden outputs (state dumps, logs, screenshots, audio hashes, save files) from the original *before* writing Rust.
3. **Core first, pixels last.** Port deterministic logic into a window-free `*-core` crate and test it headless. Add winit/wgpu only after the core matches.
4. **Vertical slices, always green.** Port one module at a time; after each, `cargo check` + its golden test pass. Never leave the tree in a half-translated state across slices.
5. **Idiomatic where free, literal where observable.** Restructure ownership (indices instead of pointers), but keep algorithms, iteration order, float op order and RNG streams identical wherever outputs depend on them.
6. **No `unsafe`, no `unwrap()` on I/O, no new global state** unless logged in `docs/PORT.md` with a reason.
7. **Don't use wgpu by reflex.** See the decision table in `assets/mappings.md`. CLI/server/logic-only → no GPU dependency.
8. **Look up APIs, don't recall them.** wgpu/winit/bevy change per release. Pin versions, read the source in `~/.cargo/registry/src/*/<crate>-<ver>/` or `cargo doc`, and start from `assets/wgpu_template` (verified to compile on wgpu 30 + winit 0.30).

## Locations

Skill dir: `$CLAUDE_PROJECT_DIR/.claude/skills/rustport` or `~/.claude/skills/rustport` (call it `$RP`).
Helpers: `$RP/scripts/{survey,scaffold,parity}.sh`. Reference: `$RP/assets/mappings.md` (idioms, crate map, wgpu notes), `$RP/assets/PORT_TEMPLATE.md`.
Work in the user's target dir (ask only if none given; default `./<name>-rs`).

## Workflow

### 0. Intake
Identify: source location, target platforms (desktop/web/mobile), fidelity goal (bit-exact / within tolerance / idiomatic with feature parity), and what must be dropped. **Ask the user (≤4 bundled questions) only for real forks** — fidelity goal, platforms, scope cuts, license constraints. Look up anything unfamiliar (library, engine, file format) yourself first. In headless mode (`-p`) don't ask: record assumptions in `docs/PORT.md` and proceed.
Check the license of the source allows a derivative port; if unclear, flag it to the user.

### 1. Survey
`bash $RP/scripts/survey.sh <src>` → languages/LOC, build files, engine & graphics-API hints, assets, tests, risk hotspots (globals, raw pointers, threads, RNG).
Then read the entry point and trace the main loop. Write down: data flow per frame, state owners, I/O boundaries (files, net, input, audio, GPU).
**Build and run the original.** If it can't be built, say so and lower the fidelity claim accordingly.

### 1b. No source? Use REA (rea.tools)
If only a shipped artifact exists (native exe/dylib, `.app`, APK, Electron/ASAR, minified JS, web app), recover behavior with **REA** instead of guessing. Check first that you are allowed to (own code, permissive license, interoperability/clean-room context); if unclear, ask the user and stop.
- Tools: `mcp__rea__*` if connected, plus the `reverse-engineer-anything` skill. If absent: `npx -y rea-agents@latest setup --dry-run --json`, show the plan to the user, apply only after approval, restart the agent. Details: `assets/rea.md`.
- Use it to: list functions/strings/resources, decompile the routines behind each feature, trace the main loop, and capture runtime behavior (browser/Electron/process) as golden data for step 3.
- Treat output as **observation / inference / unknown**; cite Evidence IDs in `docs/PORT.md`. Decompiled code is a hint about behavior - reimplement idiomatically, don't transliterate pseudo-C. Fidelity claims are bounded by what was observed.
- Pin the exact build/version inspected (hash + version) in `docs/PORT.md`; findings don't carry across versions.

### 2. Plan → `docs/PORT.md`
`bash $RP/scripts/scaffold.sh <name> <dest> [--no-gpu]` creates a workspace (`<name>-core` + `<name>` binary, wgpu skeleton unless `--no-gpu`) and copies `PORT_TEMPLATE.md` to `docs/PORT.md`. Fill in: module map (source → crate::module, with strategy), dependency map (via `assets/mappings.md`), hard problems, milestones. Order modules **leaves first** (math, containers, parsers, rules) then up to the main loop, rendering last.
Per module pick a strategy:
- **rewrite** (default): reimplement in Rust.
- **bind**: wrap the C/C++ lib via `bindgen`/`cxx` to get running early; replace later. Use for large, stable, leaf libraries (codecs, physics) when a Rust equivalent would change behavior.
- **drop**: out of scope; log why.

### 3. Golden harness (M0)
Add a small hook/patch/driver to the **original** that runs deterministic scenarios and dumps outputs into `tests/golden/<case>/…`:
- fixed RNG seed, fixed timestep, no wall-clock, scripted input sequence;
- dump per-frame or per-N-frames **state** (positions, scores, hashes) as text/JSON — numbers get tolerance;
- for rendering, dump screenshots (PNG) at chosen frames;
- for apps: input file → output file (CLI), or API request → response.
Commit goldens. Compare with `bash $RP/scripts/parity.sh tests/golden <port_out> [abs_tol] [rel_tol]` (exit 1 on mismatch). Keep original's hook patch in `tests/original_patch/` so goldens can be regenerated.
If you can't instrument the original, record what you can (screenshots, saves, stdout) and say what is *not* covered.

### 4. Port the core (M1)
For each module, in order:
1. Read the source module fully. Note every implicit behavior: integer widths, overflow, float precision, uninitialized memory, iteration order, sort stability, locale, off-by-ones, undefined behavior the original relies on.
2. Write the Rust. Apply the idiom map in `assets/mappings.md`. Keep names recognizable (snake_case of the original) so reviewers can diff mentally. Add `// src: path:line` comments on non-obvious ported logic.
3. Unit tests: port the original's tests if any; otherwise write tests from golden data.
4. `cargo fmt && cargo clippy --all-targets -- -D warnings && cargo test`. Fix before moving on.
5. Tick the module in `docs/PORT.md`.
Determinism rules: no `HashMap` iteration when order matters (use `BTreeMap`/`IndexMap`); explicit seeded RNG (re-implement the original's algorithm if the sequence matters); f32 vs f64 as in the source; same operation order for float math (no fast-math; `mul_add` changes results); fixed timestep with accumulator.
Run the headless golden comparison now. **Diverged? Bisect to the first differing frame/field, find the root cause in the original's semantics, fix, re-run.** Don't loosen tolerances to pass; only widen them with a written justification (e.g. libm differences) in `docs/PORT.md`.

### 5. Platform & rendering (M2–M3, if GUI)
1. Window/input/audio via `winit` + `cpal`/`rodio`/`kira` (see mapping table) behind thin traits so core stays headless.
2. wgpu bring-up from `assets/wgpu_template`: first a cleared window, then a triangle, then the original's simplest draw call. Check `RUST_LOG=wgpu=warn` — **zero validation errors** is a requirement.
3. Port draw code: GL state → baked pipelines, GLSL/HLSL → WGSL (try `naga` CLI first), uniform layout/padding with `bytemuck` or `encase`, NDC z∈[0,1], sRGB formats, texture origin. The gotcha list is in `assets/mappings.md` — read it before the first shader.
4. Add an **offscreen render + readback** test path so frames are compared as PNG against golden screenshots (tolerance for GPU/driver differences; use a software adapter for CI).
5. Fixed-timestep sim separate from render; handle resize/minimize/`Outdated` surface.
6. Web target only if requested: `wasm32-unknown-unknown`, `wasm-bindgen`/`trunk`; verify in a browser.

### 6. Parity & polish (M4)
- Full golden run green; list any accepted deviations in `docs/PORT.md` with cause.
- Play/drive the port yourself: actually run it and look (screenshots / terminal output). Tests passing ≠ it works.
- Performance: build `--release`, compare frame time/throughput to the original on the same scenario. Profile (`cargo flamegraph`, wgpu timestamp queries) only if slower; fix algorithmic issues before micro-opts.
- `cargo clippy -- -D warnings`, `cargo fmt --check`, README (build/run/controls), license notes.

## Failure handling
- **Build error in third-party crate version** → check the crate's changelog/examples at the pinned version; don't downgrade unless necessary.
- **Borrow-checker fights** → redesign ownership (ids/arenas/split borrows, `std::mem::take`), not `Rc<RefCell<…>>` everywhere and never `unsafe`.
- **Golden diverges** → bisect (first differing frame → first differing field → first differing function). Add temporary trace logging to *both* sides and diff them.
- **Visual mismatch** → in order: sRGB/gamma, Y flip, NDC depth range, winding/cull, blend equation/premultiplied alpha, uniform padding, texture filtering/wrap, mip levels.
- **Doom-loop guard**: same failure after 3 attempts → stop, write what you know to `docs/PORT.md`, change approach or ask the user. Don't mass-rewrite hoping it fixes itself.
- **Scope blowup** (>~50k LOC or an entire engine): propose milestones and port a vertical slice first; confirm with the user.

## Reporting
At each milestone give the user a short status: modules done/total, golden cases passing/total, known deviations, next step. Final report: what was ported, what was dropped, how to build/run, test results (real output, including failures), perf comparison, open risks. Never state "identical to the original" without parity-run evidence; say what the evidence covers.
