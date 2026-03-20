# GitHub Action: Release Versioning

This action calculates the semantic version of the repository using the [GitVersion](https://gitversion.net/) tool, and then creates a Git tag and GitHub release. Optionally you can pass in a pre-determined semantic version and that will be used instead.

## Usage

```yaml
jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    outputs:
      version: ${{ steps.release.outputs.version }}
      fullSemVer: ${{ steps.release.outputs.fullSemVer }}
      major: ${{ steps.release.outputs.major }}
      minor: ${{ steps.release.outputs.minor }}
      patch: ${{ steps.release.outputs.patch }}
    steps:
      - uses: actions/checkout@v6
        with:
          fetch-depth: 0   # required for GitVersion to read full history
      - uses: f2calv/gha-release-versioning@v1
        id: release
        with:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

> **Note:** `fetch-depth: 0` is required so GitVersion can read the full commit history to calculate the version.

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `GITHUB_TOKEN` | Yes | — | GitHub token for API access and creating releases. |
| `semVer` | No | `''` | Pass in an externally generated semantic version. When empty, GitVersion is used. |
| `tag-prefix` | No | `v` | Prefix applied to the version tag, e.g. `v1.0.1`. |
| `move-major-tag` | No | `true` | When `true`, moves rolling major (e.g. `v1`) and minor (e.g. `v1.2`) tags to the new release commit. |
| `tag-and-release` | No | `true` | When `true`, creates a Git tag and a GitHub release. |
| `gv-config` | No | `GitVersion.yml` | Path to the GitVersion configuration file. |
| `gv-source` | No | `actions` | GitVersion installation source: `actions`, `dotnet`, or `container`. |
| `gv-spec` | No | `5.x` | GitVersion version specification. Auto-detected from `gv-config` if not set explicitly. |

## Outputs

| Output | Description |
|--------|-------------|
| `version` | The calculated semantic version, e.g. `1.2.301`. |
| `semVer` | **Deprecated** — use `version` instead. |
| `fullSemVer` | The full semantic version including pre-release info, e.g. `1.2.301-feature-my-feature.12`. |
| `major` | The major version component, e.g. `1`. |
| `minor` | The minor version component, e.g. `2`. |
| `patch` | The patch version component, e.g. `301`. |
| `release-exists` | `true` if a GitHub Release already exists for this version, otherwise `false`. |

## GitVersion configuration

A `GitVersion.yml` file is required in the repository root when `gv-source` is used. The configuration schema changed between GitVersion v5 and v6 — the main difference is that branch pre-release labels are configured with `label:` in v6 (previously `tag:` in v5).

The action **auto-detects** the GitVersion version from the config file: if the config contains `label:` keys under `branches`, `6.x` is used; if it contains `tag:` keys, `5.x` is used. The auto-detected value overrides the `gv-spec` input, so in most cases you can omit `gv-spec` entirely and just supply the right config file.

### GitVersion v5 (default)

```yaml
mode: MainLine
branches:
  main:
    regex: ^main$
    tag: ''
  feature:
    regex: ^features?[/-]
    tag: useBranchName
```

### GitVersion v6

To use GitVersion v6, supply a v6-compatible config file (the action will auto-detect `6.x` from the `label:` keys):

```yaml
mode: MainLine
branches:
  main:
    regex: ^main$
    label: ''
  feature:
    regex: ^features?[/-]
    label: useBranchName
```

> **Note:** `tag:` in v5 branch config is a pre-release label setting and is not related to Git tags. In v6 this field was renamed to `label:` to avoid confusion.

## License

MIT
