# `dir_clean`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../10-directory.md) › [Function Index](README.md) › **`dir_clean`** › [Runnable Example](../../examples/10_directory_example.sh) › [Tests](../../tests/10-directory.test.sh)

- **Source:** [`functions/10-directory.sh#L202-L210`](../../functions/10-directory.sh#L202-L210)
- **Signature:** `dir_clean <dir>`
- **Description:** Deletes all files and directories inside a directory without deleting the directory itself.

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

## Return / Exit Value

- {number} 0 on success.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  dir_clean "/tmp/logs"
```

### 2. Remove all contents vs only files older than N days

```zsh
dir_clean "/tmp/app_cache"
dir_clean "/tmp/app_cache" 7  # delete files older than 7 days
```

---

See also the full runnable example script: [`examples/10_directory_example.sh`](../../examples/10_directory_example.sh).
