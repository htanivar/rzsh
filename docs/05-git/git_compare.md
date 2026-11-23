# `git_compare`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../05-git.md) › [Function Index](README.md) › **`git_compare`** › [Runnable Example](../../examples/05_git_example.sh) › [Tests](../../tests/05-git.test.sh)

- **Source:** [`functions/05-git.sh#L1934-L2012`](../../functions/05-git.sh#L1934-L2012)
- **Signature:** `git_compare --type <type> [options] [<source>] [<target>] [<extra>]`
- **Description:** Unified Git comparison dispatcher supporting `branch`, `commit`, `tag`, `release`, `content`, `worktree`, and `three-way` comparisons.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `--type\|-t <type>` (`string`) | Comparison type: `branch`, `commit`, `tag`, `release`, `content`, `worktree`, `three-way`. |
| `[options]` (`string`) | Type-specific options (`-o/--output`, `-s/--silent`, `-p/--path`, `--diff`, `--no-diff`, `--staged`). |

## Flags & Options

```text
  -t, --type <type>     Comparison type (default: branch).
      --list-types      List supported comparison types and exit.
  -h, --help            Show this help message.
  All other options (-o/--output, -s/--silent, -p/--path, --diff, --no-diff, --staged) are forwarded.
```

## Return / Exit Value

- {number} 0 on success, 1 on error.

## Copy-Paste Examples

### 1. Compare Tags, Releases, and Content

```zsh
git_compare --type tag -o "./logs/tag_diff.md" v1.0.0 v1.1.0
git_compare -t release -o "./logs/release_diff.md" release/1.0.0 release/1.1.0
git_compare -t content -p functions/05-git.sh main HEAD
```

### 2. List Supported Types

```zsh
git_compare --list-types
```

### 3. CLI Script Equivalent

```zsh
./scripts/04-git/compare_git.sh --type release -o "./logs/release_diff.md" release/1.0.0 release/1.1.0
```

---

See also the full runnable example script: [`examples/05_git_example.sh`](../../examples/05_git_example.sh).
