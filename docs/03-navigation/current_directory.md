# `current_directory`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../03-navigation.md) › [Function Index](README.md) › **`current_directory`** › [Runnable Example](../../examples/03_navigation_example.sh) › [Tests](../../tests/03-navigation.test.sh)

- **Source:** [`functions/03-navigation.sh#L23-L25`](../../functions/03-navigation.sh#L23-L25)
- **Signature:** `current_directory`
- **Description:** Returns the absolute path of the current working directory.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| — | None |

## Return / Exit Value

- {string} The absolute path.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local cur
  cur=$(current_directory)
```

---

See also the full runnable example script: [`examples/03_navigation_example.sh`](../../examples/03_navigation_example.sh).
