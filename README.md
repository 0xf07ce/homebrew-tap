# 0xf07ce homebrew tap

Homebrew tap for 0xf07ce's projects.

## Install

```bash
brew install 0xf07ce/tap/vtplayer
```

Or tap first:

```bash
brew tap 0xf07ce/tap
brew install vtplayer
```

## Available formulae

| Formula | Description |
|---------|-------------|
| [vtplayer](Formula/vtplayer.rb) | Terminal-based music player (MP3 / OGG / FLAC / WAV) with spectrum visualizer |

## Uninstall

```bash
brew uninstall vtplayer
brew untap 0xf07ce/tap
```

## Maintenance — vtplayer release automation

`Formula/vtplayer.rb` is the authoritative formula and is **machine-managed**
by the release workflow in the `0xf07ce/vtplayer` repo
(`.github/workflows/release.yml`). Do not hand-edit the `url` / source
`sha256`, the `ventty` resource `sha256`, or the `bottle do` block — the
workflow rewrites them on each release.

### What the workflow automates

On `git push origin vX.Y.Z` (or `workflow_dispatch`) in the vtplayer repo,
`release.yml`:

1. **prepare** — ensures the GitHub Release exists, then bumps this formula's
   `url`, source `sha256`, the bottle `root_url`, and the `ventty` resource
   `sha256` to the new tag, and commits to this tap.
2. **bottle** (macos-15, macos-26) — `brew install --build-bottle` then
   `brew bottle --json`, uploads the bottle tarball to the GitHub Release and
   the `.json` as a workflow artifact.
3. **merge** — runs `brew bottle --merge --write --no-commit` over all bottle
   JSONs to rewrite the `bottle do` block and commits it here.

### One-time setup (already done)

- **`TAP_PUSH_TOKEN` secret** on the `0xf07ce/vtplayer` repo (Settings →
  Secrets and variables → Actions): a fine-grained Personal Access Token with
  **Contents: Read and write** on `0xf07ce/homebrew-tap`. The default
  `GITHUB_TOKEN` cannot push cross-repo, so this token is required.

### ventty resource sha bump

`prepare` updates the `ventty` resource to the tag in vtplayer's
`deps/CMakeLists.txt` (`FetchContent_Declare(ventty ... GIT_TAG vX.Y.Z)`).
When bumping ventty, change the `GIT_TAG` there and the workflow keeps this
formula's resource in sync.
