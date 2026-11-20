# `normalize_path`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../03-navigation.md) › [Function Index](README.md) › **`normalize_path`** › [Runnable Example](../../examples/03_navigation_example.sh) › [Tests](../../tests/03-navigation.test.sh)

- **Source:** [`functions/03-navigation.sh#L124-L127`](../../functions/03-navigation.sh#L124-L127)
- **Signature:** `normalize_path <path>`
- **Description:** Normalizes a path by resolving relative components (. and ..) and symbolic links.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `path` (`string`) | The path to normalize. |

## Return / Exit Value

- {string} The normalized path.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local clean
  clean=$(normalize_path "/a/b/../c")
```

---

See also the full runnable example script: [`examples/03_navigation_example.sh`](../../examples/03_navigation_example.sh).
