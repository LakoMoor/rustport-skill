# rustport website

The public GitHub Pages source is [../docs/](../docs/) on main. Buildless HTML,
CSS and JavaScript; no build action or package installation required.

From the repository root:

```sh
node site/check.mjs
python3 -m http.server 8764 --directory docs
```

Production: https://lakomoor.github.io/claude-rustport-skill/

Pages publishes main:/docs. Installation commands and documentation links target
main. Evidence notes distinguish measured CLI tests from static-only binary
recovery. The landscape is a vector illustration, not a real parity result.
