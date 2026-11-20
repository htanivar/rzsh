# `cache_has`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../19-cache.md) › [Function Index](README.md) › **`cache_has`** › [Runnable Example](../../examples/19_cache_example.sh) › [Tests](../../tests/19-cache.test.sh)

- **Source:** [`functions/19-cache.sh#L276-L288`](../../functions/19-cache.sh#L276-L288)
- **Signature:** `cache_has <key>`
- **Description:** Checks whether a valid, non-expired secret exists in the cache for the given key.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `key` (`string`) | Cache key or organized path. |

## Return / Exit Value

- {number} 0 if present and valid, 1 if missing or expired.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  if cache_has "payments/prod/jwt"; then
    echo "Using cached token"
  fi
```

---

See also the full runnable example script: [`examples/19_cache_example.sh`](../../examples/19_cache_example.sh).
