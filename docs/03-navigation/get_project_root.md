# `get_project_root`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../03-navigation.md) › [Function Index](README.md) › **`get_project_root`** › [Runnable Example](../../examples/03_navigation_example.sh) › [Tests](../../tests/03-navigation.test.sh)

- **Source:** [`functions/03-navigation.sh#L94-L96`](../../functions/03-navigation.sh#L94-L96)
- **Signature:** `get_project_root`
- **Description:** Returns the absolute path of the project root directory.

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

- {string} The project root path.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local root
  root=$(get_project_root)
```

---

See also the full runnable example script: [`examples/03_navigation_example.sh`](../../examples/03_navigation_example.sh).
