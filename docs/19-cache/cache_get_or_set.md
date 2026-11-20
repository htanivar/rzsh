# `cache_get_or_set`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../19-cache.md) › [Function Index](README.md) › **`cache_get_or_set`** › [Runnable Example](../../examples/19_cache_example.sh) › [Tests](../../tests/19-cache.test.sh)

- **Source:** [`functions/19-cache.sh#L479-L508`](../../functions/19-cache.sh#L479-L508)
- **Signature:** `cache_get_or_set <key> <ttl_seconds> <command...>`
- **Description:** Returns the cached secret if valid; otherwise executes the provided command, caches its stdout, and prints it.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `key` (`string`) | Cache key or organized path (e.g., "myapp/prod/jwt"). |
| `ttl_seconds` (`number`) | TTL in seconds (0 = persistent/auto-detect JWT exp; pass "" or 0 as appropriate). |
| `command...` (`string`) | Command and arguments to execute on cache miss to obtain the secret. |

## Return / Exit Value

- {number} 0 on success, non-zero if the command fails or produces empty output.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  token=$(cache_get_or_set "payments/prod/jwt" 3600 my_login_func "prod")
```

### 2. Cache-aside login deduplication

```zsh
token=$(cache_get_or_set "payments/prod/jwt" 3600 login_to_service "prod")
```

---

See also the full runnable example script: [`examples/19_cache_example.sh`](../../examples/19_cache_example.sh).
