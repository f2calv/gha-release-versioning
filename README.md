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
| ----- | -------- | ------- | ----------- |
| `GITHUB_TOKEN` | Yes | — | GitHub token for API access and creating releases. |
| `semVer` | No | `''` | Pass in an externally generated semantic version. When empty, GitVersion is used. |
| `tag-prefix` | No | `v` | Prefix applied to the version tag, e.g. `v1.0.1`. |
| `move-major-tag` | No | `true` | When `true`, moves rolling major (e.g. `v1`) and minor (e.g. `v1.2`) tags to the new release commit. |
| `tag-and-release` | No | `true` | When `true`, creates a Git tag and a GitHub release. |
| `gv-config` | No | `GitVersion.yml` | Path to the GitVersion configuration file. |
| `gv-source` | No | `actions` | GitVersion installation source: `actions`, `dotnet`, or `container`. |
| `dotnet-version` | No | `10.0.x` | .NET SDK version to install when `gv-source` is `dotnet`. |

## Outputs

| Output | Description |
| ------ | ----------- |
| `version` | The calculated semantic version, e.g. `1.2.301`. |
| `semVer` | **Deprecated** — use `version` instead. |
| `fullSemVer` | The full semantic version including pre-release info, e.g. `1.2.301-feature-my-feature.12`. |
| `major` | The major version component, e.g. `1`. |
| `minor` | The minor version component, e.g. `2`. |
| `patch` | The patch version component, e.g. `301`. |
| `release-exists` | `true` if a GitHub Release already exists for this version, otherwise `false`. |

## GitVersion configuration

A `GitVersion.yml` file is required in the repository root when `gv-source` is used. The configuration schema changed between GitVersion v5 and v6 — the main difference is that branch pre-release labels are configured with `label:` in v6 (previously `tag:` in v5).

The action **auto-detects** the GitVersion version from the config file: if the config contains `label:` keys under `branches`, `6.x` is used; if it contains `tag:` keys, `5.x` is used. There is no need to specify the version manually.

### GitVersion v5

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

### GitVersion v6 (default)

```yaml
mode: ContinuousDeployment
branches:
  main:
    regex: ^main$
    label: ''
  feature:
    regex: ^features?[/-]
    label: useBranchName
```

> **Note:** `tag:` in v5 branch config is a pre-release label setting and is not related to Git tags. In v6 this field was renamed to `label:` to avoid confusion. The `mode` value also changed: `MainLine` in v5 became `ContinuousDeployment` in v6 (both produce clean versions on the default branch without requiring a pre-existing tag).

## `gv-source` options

| Source | GitVersion v5 | GitVersion v6 | Notes |
| ------ | ------------- | ------------- | ----- |
| `actions` | ✅ via `gittools/actions@v3` | ✅ via `gittools/actions@v4` | Auto-selects the correct action version based on the detected spec. |
| `dotnet` | ✅ | ✅ | Installs `GitVersion.Tool` at the correct major version. |
| `container` | ✅ image tag `5.12.0` | ✅ image tag `latest` | Runs the official `gittools/gitversion` Docker image. |

## License

MIT
