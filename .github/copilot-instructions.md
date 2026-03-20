# Copilot Instructions

## GitHub Actions workflow conventions

- Always leave **one blank line between steps** within a job for readability.
- Pin actions to a specific major version tag (e.g. `actions/checkout@v6`, `softprops/action-gh-release@v2.6.1`).
- Set `fetch-depth: 0` on `actions/checkout` whenever GitVersion is used so it can read the full commit history.
- Use explicit `permissions` blocks on every job; default to the minimum required (e.g. `contents: read`).
