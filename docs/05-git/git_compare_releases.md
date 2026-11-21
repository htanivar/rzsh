# `git_compare_releases`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../05-git.md) › [Function Index](README.md) › **`git_compare_releases`** › [Runnable Example](../../examples/05_git_example.sh) › [Tests](../../tests/05-git.test.sh)

- **Source:** [`functions/05-git.sh#L1692-L1774`](../../functions/05-git.sh#L1692-L1774)
- **Signature:** `git_compare_releases [options] [<release_a>] [<release_b>]`
- **Description:** Compares two releases (branches like `release/1.0.0` or tags like `v1.0.0`) to pinpoint scope creep, commit gaps, contributors, and file diffs.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `[options]` (`string`) | `-h/--help`, `-o/--output <file>`, `-s/--silent`, `--no-diff`. |
| `[release_a]` (`string`) | Base/previous release branch or tag. |
| `[release_b]` (`string`) | Target/new release branch or tag (defaults to current branch if 1 arg). |

## Flags & Options

```text
  -h, --help            Show this help message.
  -o, --output <file>   Write the Markdown report to <file>.
  -s, --silent          Suppress stdout output.
      --no-diff         Omit per-file unified diffs from the report.
```

## Return / Exit Value

- {number} 0 on success, 1 on failure.

## Copy-Paste Examples

### 1. Compare Two Release Branches

```zsh
git_compare_releases -o "./logs/release_diff.md" release/1.0.0 release/1.1.0
```

### 2. Auto-Detect Latest Two Releases

```zsh
git_compare_releases --silent -o "./logs/release_diff.md"
```

---

See also the full runnable example script: [`examples/05_git_example.sh`](../../examples/05_git_example.sh).
