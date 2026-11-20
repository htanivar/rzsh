# `cache_get`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../19-cache.md) › [Function Index](README.md) › **`cache_get`** › [Runnable Example](../../examples/19_cache_example.sh) › [Tests](../../tests/19-cache.test.sh)

- **Source:** [`functions/19-cache.sh#L241-L264`](../../functions/19-cache.sh#L241-L264)
- **Signature:** `cache_get <key>`
- **Description:** Retrieves a valid (non-expired) secret or token from the cache. Removes and fails if expired.

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

## Return / Exit Value

- {string} Prints the cached secret value to stdout on success; returns 1 if missing or expired.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  token=$(cache_get "payments/prod/jwt") || token=$(login_and_get_token)
```

---

See also the full runnable example script: [`examples/19_cache_example.sh`](../../examples/19_cache_example.sh).
