# `cache_ttl`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../19-cache.md) › [Function Index](README.md) › **`cache_ttl`** › [Runnable Example](../../examples/19_cache_example.sh) › [Tests](../../tests/19-cache.test.sh)

- **Source:** [`functions/19-cache.sh#L298-L322`](../../functions/19-cache.sh#L298-L322)
- **Signature:** `cache_ttl <key>`
- **Description:** Returns the remaining time-to-live in seconds for a cached secret (0 if persistent / no expiry).

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

- {string} Remaining seconds (or 0 for persistent entries); returns 1 if missing or expired.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  remaining=$(cache_ttl "payments/prod/jwt")
```

---

See also the full runnable example script: [`examples/19_cache_example.sh`](../../examples/19_cache_example.sh).
