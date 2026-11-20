# `dir_list`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../10-directory.md) › [Function Index](README.md) › **`dir_list`** › [Runnable Example](../../examples/10_directory_example.sh) › [Tests](../../tests/10-directory.test.sh)

- **Source:** [`functions/10-directory.sh#L120-L135`](../../functions/10-directory.sh#L120-L135)
- **Signature:** `dir_list <dir> [pattern=*]`
- **Description:** Lists files and folders directly inside a directory that match a pattern.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `dir` (`string`) | Directory path. |
| `[pattern=*]` (`string`) | Glob pattern to filter results. |

## Return / Exit Value

- {string} Newline-separated list of filenames.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  dir_list "/tmp" "*.txt"
```

### 2. List all files vs glob pattern filter

```zsh
dir_list "./src"
dir_list "./src" "*.sh"
dir_list "./logs" "*.log"
```

---

See also the full runnable example script: [`examples/10_directory_example.sh`](../../examples/10_directory_example.sh).
