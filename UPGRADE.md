# rustport Workbench upgrade (local integration package)

This overlay augments **LakoMoor/rustport-skill** without deleting the user's existing files or Git history. Tested with Python 3.13, standard library only. It is original new implementation and is intended to be licensed under this repository's Apache-2.0 license.

## Apply to a clone

```bash
git clone https://github.com/LakoMoor/rustport-skill.git
cd rustport-skill
python3 /path/to/extracted-rustport-next/apply_upgrade.py .
python3 -m unittest discover -s tests -v
node site/check.mjs   # optional, if Node.js is available

git diff --check
git add .
git commit -m 'feat: evidence workbench, scenario runner and parity-aware site'
git push origin main
```

The upgrade program refuses missing expected anchors in critical files and refuses overwrite of existing nonmatching new files. Run on a clean clone; inspect `git diff` before commit. It updates README/SKILL/compatible-runtime, updates the landing page and styling, improves parity/scaffold scripts, and adds standalone Workbench docs, runnable tooling and tests. It does not install external dependencies, download originals or execute third-party games.

## Status of upstream publishing

The linked GitHub integration returned `403 Resource not accessible by integration` for creating both a branch and a Git blob. This archive is the tested *local* upgrade; publishing via connector requires the linked GitHub App to be granted contents write access to the repository. The site only changes after files are actually pushed and GitHub Pages deployment completes.

## Provenance and limits

The workbench can compare JSONL traces and preserve hashes. It cannot itself certify that an agent did not invent the original trace, nor fully replicate Ghidra+Unicorn automation from GameFrame. It should never be advertised as independently benchmarked better than GameFrame; conduct blinded same-game and same-budget trials before making comparative performance claims.
