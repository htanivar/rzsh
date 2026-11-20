# `cache_set`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../19-cache.md) › [Function Index](README.md) › **`cache_set`** › [Runnable Example](../../examples/19_cache_example.sh) › [Tests](../../tests/19-cache.test.sh)

- **Source:** [`functions/19-cache.sh#L155-L231`](../../functions/19-cache.sh#L155-L231)
- **Signature:** `cache_set <key> <value> [ttl_seconds]`
- **Description:** Stores a secret or token in the organized .secrets.d cache with an optional TTL in seconds. Auto-detects JWT 'exp' claim when ttl_seconds is omitted.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `key` (`string`) | Cache key or organized path (e.g., "myapp/prod/jwt_token"). |
| `value` (`string`) | Secret or token value to store. |
| `[ttl_seconds]` (`number`) | Time-to-live in seconds (0 = persistent). Omit to auto-detect JWT 'exp' or store persistently. |

## Return / Exit Value

- {number} 0 on success, 1 on invalid input or write failure.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  cache_set "payments/prod/jwt" "${token}" 3600
```

### 2. Explicit TTL in seconds

```zsh
cache_set "payments/prod/api_key" "sk_live_123" 3600
```

### 3. Auto-detect JWT exp claim (omit TTL)

```zsh
cache_set "payments/prod/jwt" "${jwt_token}"
```

### 4. Persistent secret with no expiry (TTL = 0)

```zsh
cache_set "payments/dev/client_id" "client-xyz" 0
```

---

See also the full runnable example script: [`examples/19_cache_example.sh`](../../examples/19_cache_example.sh).
