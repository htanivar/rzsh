# `cache_remove`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../19-cache.md) › [Function Index](README.md) › **`cache_remove`** › [Runnable Example](../../examples/19_cache_example.sh) › [Tests](../../tests/19-cache.test.sh)

- **Source:** [`functions/19-cache.sh#L332-L352`](../../functions/19-cache.sh#L332-L352)
- **Signature:** `cache_remove <key>`
- **Description:** Removes a cached secret entry and cleans up any empty parent directories under SECRETS_DIR.

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

- {number} 0 if removed, 1 if not found or invalid key.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  cache_remove "payments/prod/jwt"
```

---

See also the full runnable example script: [`examples/19_cache_example.sh`](../../examples/19_cache_example.sh).
