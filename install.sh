#!/usr/bin/env bash
# Install the rustport skill into ~/.claude/skills (or ./.claude/skills with --project).
set -eu
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dest="$HOME/.claude/skills/rustport"
[ "${1:-}" = "--project" ] && dest="$PWD/.claude/skills/rustport"
mkdir -p "$dest"
cp -R "$here/SKILL.md" "$here/scripts" "$here/assets" "$dest/"
chmod +x "$dest"/scripts/*.sh
echo "installed -> $dest"
