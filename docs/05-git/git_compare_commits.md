# `git_compare_commits`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../05-git.md) › [Function Index](README.md) › **`git_compare_commits`** › [Runnable Example](../../examples/05_git_example.sh) › [Tests](../../tests/05-git.test.sh)

- **Source:** [`functions/05-git.sh#L1053-L1199`](../../functions/05-git.sh#L1053-L1199)
- **Signature:** `git_compare_commits [options] <ref1> [<ref2>]`
- **Description:** Compares two Git commits, tags, or refs (defaulting the second ref to HEAD) and generates a Markdown report with commit metadata, changed files, diff stats, and optional patch diff.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `[options]` (`string`) | -h/--help, -o/--output <file>, -s/--silent, --diff. |
| `ref1` (`string`) | Base commit hash, tag, or branch ref. |
| `[ref2=HEAD]` (`string`) | Target commit hash, tag, or branch ref. |

## Flags & Options

```text
-h, --help            Show this help message.
  -o, --output <file>   Write the Markdown comparison report to <file>.
  -s, --silent          Suppress stdout output (still writes to -o if specified).
      --diff            Include full unified patch diff in the report.
```

## Return / Exit Value

- {number} 0 on success, 1 on error or invalid ref.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  git_compare_commits --diff -o commit_diff.md HEAD~2 HEAD
```

### 2. Compare a commit/tag against HEAD

```zsh
git_compare_commits "HEAD~3"
git_compare_commits "v1.0.0"
```

### 3. Compare two explicit refs

```zsh
git_compare_commits "HEAD~5" "HEAD~1"
```

### 4. Include full patch diff (--diff) and write silently (-s -o)

```zsh
git_compare_commits --diff "HEAD~2" "HEAD"
git_compare_commits -s --diff -o "./logs/commit_diff.md" "v1.0.0" "HEAD"
```

### 5. Show help (-h / --help)

```zsh
git_compare_commits --help
```

---

See also the full runnable example script: [`examples/05_git_example.sh`](../../examples/05_git_example.sh).
