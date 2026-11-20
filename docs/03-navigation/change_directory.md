# `change_directory`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../03-navigation.md) › [Function Index](README.md) › **`change_directory`** › [Runnable Example](../../examples/03_navigation_example.sh) › [Tests](../../tests/03-navigation.test.sh)

- **Source:** [`functions/03-navigation.sh#L153-L159`](../../functions/03-navigation.sh#L153-L159)
- **Signature:** `change_directory <path>`
- **Description:** Changes the current working directory to the specified path.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `path` (`string`) | The directory path to change to. |

## Return / Exit Value

- {number} 0 on success, or 1 on failure.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  change_directory "/tmp"
```

---

See also the full runnable example script: [`examples/03_navigation_example.sh`](../../examples/03_navigation_example.sh).
