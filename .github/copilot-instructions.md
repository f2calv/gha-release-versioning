# Copilot Instructions

## GitHub Actions workflow conventions

- Always leave **one blank line between steps** within a job for readability.
- Pin actions to the **major version tag only** (e.g. `actions/checkout@v6`, `softprops/action-gh-release@v2`). Do not include minor or patch versions in action pins.
- Set `fetch-depth: 0` on `actions/checkout` whenever GitVersion is used so it can read the full commit history.
- Use explicit `permissions` blocks on every job; default to the minimum required (e.g. `contents: read`).
