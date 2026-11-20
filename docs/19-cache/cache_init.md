# `cache_init`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../19-cache.md) › [Function Index](README.md) › **`cache_init`** › [Runnable Example](../../examples/19_cache_example.sh) › [Tests](../../tests/19-cache.test.sh)

- **Source:** [`functions/19-cache.sh#L125-L143`](../../functions/19-cache.sh#L125-L143)
- **Signature:** `cache_init [dir]`
- **Description:** Initializes the secrets cache directory (SECRETS_DIR or a custom path) with owner-only permissions (0700).

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `[dir]` (`string`) | Optional custom directory path (defaults to SECRETS_DIR). |

## Return / Exit Value

- {number} 0 on success, 1 on failure.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  cache_init
```

---

See also the full runnable example script: [`examples/19_cache_example.sh`](../../examples/19_cache_example.sh).
