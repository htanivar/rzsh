# `git_compare_content`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../05-git.md) › [Function Index](README.md) › **`git_compare_content`** › [Runnable Example](../../examples/05_git_example.sh) › [Tests](../../tests/05-git.test.sh)

- **Source:** [`functions/05-git.sh#L1786-L1848`](../../functions/05-git.sh#L1786-L1848)
- **Signature:** `git_compare_content [options] <source_ref> [<target_ref>]`
- **Description:** Compares file or directory content between two Git refs (branch, commit, tag) optionally scoped by `-p/--path`.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `[options]` (`string`) | `-h/--help`, `-o/--output <file>`, `-s/--silent`, `-p/--path <path>`. |
| `source_ref` (`string`) | Base Git ref (branch, commit, or tag). |
| `[target_ref=HEAD]` (`string`) | Target Git ref. |

## Flags & Options

```text
  -h, --help            Show this help message.
  -o, --output <file>   Write the Markdown report to <file>.
  -s, --silent          Suppress stdout output.
  -p, --path <path>     Limit content comparison to a specific file or directory (repeatable).
```

## Return / Exit Value

- {number} 0 on success, 1 on failure.

## Copy-Paste Examples

### 1. Compare Specific File Across Refs

```zsh
git_compare_content -p functions/05-git.sh -o "./logs/content_diff.md" main HEAD
```

### 2. Compare Multiple Paths

```zsh
git_compare_content -p functions/ -p scripts/04-git/ HEAD~3 HEAD
```

---

See also the full runnable example script: [`examples/05_git_example.sh`](../../examples/05_git_example.sh).
