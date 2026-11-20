# `to_project_root`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../03-navigation.md) › [Function Index](README.md) › **`to_project_root`** › [Runnable Example](../../examples/03_navigation_example.sh) › [Tests](../../tests/03-navigation.test.sh)

- **Source:** [`functions/03-navigation.sh#L78-L83`](../../functions/03-navigation.sh#L78-L83)
- **Signature:** `to_project_root`
- **Description:** Changes the current working directory to the project root directory.

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

- {number} 0 on success, or 1 if PROJECT_ROOT is not set or directory change fails.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  to_project_root
```

---

See also the full runnable example script: [`examples/03_navigation_example.sh`](../../examples/03_navigation_example.sh).
