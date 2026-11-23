# `git_compare_working_tree`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../05-git.md) › [Function Index](README.md) › **`git_compare_working_tree`** › [Runnable Example](../../examples/05_git_example.sh) › [Tests](../../tests/05-git.test.sh)

- **Source:** [`functions/05-git.sh#L1859-L1922`](../../functions/05-git.sh#L1859-L1922)
- **Signature:** `git_compare_working_tree [options] [<base_ref>]`
- **Description:** Compares the working tree or staged index against `HEAD` (or a specified ref) and generates a Markdown report.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `[options]` (`string`) | `-h/--help`, `-o/--output <file>`, `-s/--silent`, `--staged`, `-p/--path <path>`. |
| `[base_ref=HEAD]` (`string`) | Base ref to compare against. |

## Flags & Options

```text
  -h, --help            Show this help message.
  -o, --output <file>   Write the Markdown report to <file>.
  -s, --silent          Suppress stdout output.
      --staged          Compare only staged changes (--cached) against <base_ref>.
  -p, --path <path>     Limit comparison to a specific file or directory (repeatable).
```

## Return / Exit Value

- {number} 0 on success, 1 on failure.

## Copy-Paste Examples

### 1. Compare Unstaged Working Tree Against HEAD

```zsh
git_compare_working_tree -o "./logs/worktree_diff.md"
```

### 2. Compare Staged Changes Only

```zsh
git_compare_working_tree --staged -o "./logs/staged_diff.md"
```

---

See also the full runnable example script: [`examples/05_git_example.sh`](../../examples/05_git_example.sh).
