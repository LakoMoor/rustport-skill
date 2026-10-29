# rustport website

Buildless HTML/CSS/JavaScript landing page. Apache-2.0, like the original rustport
material. The landscape is an inline vector illustration, not a real parity result.

From this directory:

```sh
node check.mjs
python3 -m http.server 8764 --directory dist
```

The installation selector targets `codex/portable-rustport` while the multi-agent
changes are in PR #1. Update clone commands and documentation links after merging.
The field notes distinguish measured CLI coverage from static-only binary recovery.

Sites deployment identity and access configuration are maintained separately from
this public source snapshot. No hosting credentials or private manifest is included.
