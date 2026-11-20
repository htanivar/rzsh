# `cache_list`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../19-cache.md) › [Function Index](README.md) › **`cache_list`** › [Runnable Example](../../examples/19_cache_example.sh) › [Tests](../../tests/19-cache.test.sh)

- **Source:** [`functions/19-cache.sh#L433-L467`](../../functions/19-cache.sh#L433-L467)
- **Signature:** `cache_list [prefix]`
- **Description:** Lists cached secret keys and their expiry status (never prints secret values).

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `[prefix]` (`string`) | Optional key prefix filter (e.g., "payments/prod"). |

## Return / Exit Value

- {number} 0 on success.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  cache_list "payments"
```

### 2. List all cached keys vs filtered by prefix

```zsh
cache_list
cache_list "payments/prod"
```

---

See also the full runnable example script: [`examples/19_cache_example.sh`](../../examples/19_cache_example.sh).
