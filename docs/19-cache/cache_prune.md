# `cache_prune`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../19-cache.md) › [Function Index](README.md) › **`cache_prune`** › [Runnable Example](../../examples/19_cache_example.sh) › [Tests](../../tests/19-cache.test.sh)

- **Source:** [`functions/19-cache.sh#L402-L423`](../../functions/19-cache.sh#L402-L423)
- **Signature:** `cache_prune`
- **Description:** Scans the secrets cache directory and removes all expired entries and empty subdirectories. Prints the count of pruned entries.

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

- {number} 0 on success.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  pruned_count=$(cache_prune)
```

---

See also the full runnable example script: [`examples/19_cache_example.sh`](../../examples/19_cache_example.sh).
