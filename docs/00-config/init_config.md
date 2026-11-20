# `init_config`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../00-config.md) › [Function Index](README.md) › **`init_config`** › [Runnable Example](../../examples/00_config_example.sh) › —

- **Source:** [`config/config.sh#L69-L170`](../../config/config.sh#L69-L170)
- **Signature:** `init_config`
- **Description:** Initializes the global configuration variables for the framework, setting defaults if they are not already defined in the environment.

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

- {number} 0 on success, or non-zero on failure.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  init_config
```

---

See also the full runnable example script: [`examples/00_config_example.sh`](../../examples/00_config_example.sh).
