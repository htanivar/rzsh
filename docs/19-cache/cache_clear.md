# `cache_clear`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../19-cache.md) › [Function Index](README.md) › **`cache_clear`** › [Runnable Example](../../examples/19_cache_example.sh) › [Tests](../../tests/19-cache.test.sh)

- **Source:** [`functions/19-cache.sh#L363-L392`](../../functions/19-cache.sh#L363-L392)
- **Signature:** `cache_clear [prefix]`
- **Description:** Clears all cached secrets, or all secrets under a specific app/env prefix.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `[prefix]` (`string`) | Optional key prefix (e.g., "payments/prod" or "payments"). |

## Return / Exit Value

- {number} 0 on success, 1 on invalid prefix.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  cache_clear "payments/staging"
  cache_clear
```

### 2. Clear a specific environment or app prefix

```zsh
cache_clear "payments/staging"
cache_clear "payments"
```

### 3. Clear entire .secrets.d cache

```zsh
cache_clear
```

---

See also the full runnable example script: [`examples/19_cache_example.sh`](../../examples/19_cache_example.sh).
