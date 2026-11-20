# `git_compare_three_branches`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../05-git.md) › [Function Index](README.md) › **`git_compare_three_branches`** › [Runnable Example](../../examples/05_git_example.sh) › [Tests](../../tests/05-git.test.sh)

- **Source:** [`functions/05-git.sh#L804-L1041`](../../functions/05-git.sh#L804-L1041)
- **Signature:** `git_compare_three_branches [options] <release_x> <release_prev> [<default_branch>]`
- **Description:** Compares two release branches (release/x and release/x-1) against a default branch

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
| `<release_x>` (`string`) | Current/newer release branch (e.g., release/2.2.0). |
| `<release_prev>` (`string`) | Previous release branch (e.g., release/2.1.0). |
| `[default_branch]` (`string`) | Default/develop branch (auto-detected via git_detect_default_branch if omitted). |

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
  git_compare_three_branches --output "./three_branch_report.md" release/2.2.0 release/2.1.0 develop
```

### 2. Explicit default branch

```zsh
git_compare_three_branches "release/2.2.0" "release/2.1.0" "develop"
```

### 3. Auto-detect default branch

```zsh
git_compare_three_branches "release/2.2.0" "release/2.1.0"
```

### 4. Silent mode with custom Markdown output (-s / --silent, -o / --output)

```zsh
git_compare_three_branches --silent --output "./logs/3way.md" "release/2.2.0" "release/2.1.0" "develop"
```

### 5. Show help (-h / --help)

```zsh
git_compare_three_branches --help
```

---

See also the full runnable example script: [`examples/05_git_example.sh`](../../examples/05_git_example.sh).
