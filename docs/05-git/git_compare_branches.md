# `git_compare_branches`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../05-git.md) › [Function Index](README.md) › **`git_compare_branches`** › [Runnable Example](../../examples/05_git_example.sh) › [Tests](../../tests/05-git.test.sh)

- **Source:** [`functions/05-git.sh#L201-L586`](../../functions/05-git.sh#L201-L586)
- **Signature:** `git_compare_branches [options] [<branch_a>] [<branch_b>]`
- **Description:** Compares two git branches, outputs a structured summary, and optionally writes a Markdown report.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `[--help\|-h]` (`string`) | Show help message. |
| `[--output\|-o` (`string`) | <file>] - Write the Markdown report to a specific file. |
| `[--silent\|-s]` (`string`) | Do not output details to stdout. |
| `[branch_a]` (`string`) | The first branch to compare (default: current branch). |
| `[branch_b]` (`string`) | The second branch to compare (default: default branch of repo). |

## Flags & Options

```text
-h, --help           Show this help message.
  -o, --output <file>  Write the Markdown report to a specific file.
  -s, --silent         Do not output details to stdout (still writes to file if specified).
```

## Return / Exit Value

- {number} 0 on success, or 1 on failure.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  git_compare_branches --silent --output "./report.md" main feature
```

### 2. Compare default branch against current branch

```zsh
git_compare_branches
```

### 3. Compare two explicit branches

```zsh
git_compare_branches "main" "feature/auth"
```

### 4. Silent mode with custom Markdown output (-s / --silent, -o / --output)

```zsh
git_compare_branches -s -o "./logs/branch_diff.md" "main" "feature/auth"
git_compare_branches --silent --output "./logs/branch_diff.md" "develop" "release/1.0.0"
```

### 5. Show help (-h / --help)

```zsh
git_compare_branches --help
```

---

See also the full runnable example script: [`examples/05_git_example.sh`](../../examples/05_git_example.sh).
