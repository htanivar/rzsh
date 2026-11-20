# `dir_watch`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../10-directory.md) › [Function Index](README.md) › **`dir_watch`** › [Runnable Example](../../examples/10_directory_example.sh) › [Tests](../../tests/10-directory.test.sh)

- **Source:** [`functions/10-directory.sh#L296-L325`](../../functions/10-directory.sh#L296-L325)
- **Signature:** `dir_watch <dir> <callback> [iterations=5]`
- **Description:** Watches a directory for file system changes and runs a callback function.

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
| `callback` (`string`) | Callback function name. |
| `[iterations=5]` (`number`) | Number of iterations to poll in non-interactive/test environments. Pass '0' for infinite. |

## Return / Exit Value

- {void}

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  on_change() {
    echo "Change detected: $1"
  }
  dir_watch "/tmp/app" "on_change" 3
```

---

See also the full runnable example script: [`examples/10_directory_example.sh`](../../examples/10_directory_example.sh).
