# Secrets & Token Cache — Function Index

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../19-cache.md) › **19-cache/** › [Runnable Example](../../examples/19_cache_example.sh) › [Tests](../../tests/19-cache.test.sh)

- **Source File:** [`functions/19-cache.sh`](../../functions/19-cache.sh)
- **Runnable Example:** [`examples/19_cache_example.sh`](../../examples/19_cache_example.sh)

| Function | Signature | Description |
| :--- | :--- | :--- |
| [`cache_init`](cache_init.md) | `cache_init [dir]` | Initializes the secrets cache directory (SECRETS_DIR or a custom path) with owner-only permissions (0700). |
| [`cache_set`](cache_set.md) | `cache_set <key> <value> [ttl_seconds]` | Stores a secret or token in the organized .secrets.d cache with an optional TTL in seconds. Auto-detects JWT 'exp' claim when ttl_seconds is omitted. |
| [`cache_get`](cache_get.md) | `cache_get <key>` | Retrieves a valid (non-expired) secret or token from the cache. Removes and fails if expired. |
| [`cache_has`](cache_has.md) | `cache_has <key>` | Checks whether a valid, non-expired secret exists in the cache for the given key. |
| [`cache_ttl`](cache_ttl.md) | `cache_ttl <key>` | Returns the remaining time-to-live in seconds for a cached secret (0 if persistent / no expiry). |
| [`cache_remove`](cache_remove.md) | `cache_remove <key>` | Removes a cached secret entry and cleans up any empty parent directories under SECRETS_DIR. |
| [`cache_clear`](cache_clear.md) | `cache_clear [prefix]` | Clears all cached secrets, or all secrets under a specific app/env prefix. |
| [`cache_prune`](cache_prune.md) | `cache_prune` | Scans the secrets cache directory and removes all expired entries and empty subdirectories. Prints the count of pruned entries. |
| [`cache_list`](cache_list.md) | `cache_list [prefix]` | Lists cached secret keys and their expiry status (never prints secret values). |
| [`cache_get_or_set`](cache_get_or_set.md) | `cache_get_or_set <key> <ttl_seconds> <command...>` | Returns the cached secret if valid; otherwise executes the provided command, caches its stdout, and prints it. |
