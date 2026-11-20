# Secrets & Token Cache Module Reference

**Navigation:** [README](../README.md) › [GLOSSARY](../GLOSSARY.md) › **19-cache.md** › [Example](../examples/19_cache_example.sh) › [Tests](../tests/19-cache.test.sh)

- **Source File:** [`functions/19-cache.sh`](../functions/19-cache.sh)
- **Description:** Persistent, organized secrets and token cache stored under `SECRETS_DIR` (`.secrets.d` by default) with TTL expiration, automatic JWT `exp` claim detection, prefix-based clearing, pruning, and `cache_get_or_set` to avoid repeated login attempts across applications and environments.

---

## Detailed Usage Examples

### Integration Setup
To use the Secrets & Token Cache module, source the configuration script via `RZSH_DIR`, which automatically imports it and sets `SECRETS_DIR` (defaulting to `${PROJECT_ROOT}/.secrets.d`):

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
init_logging
```

### Organized Storage Layout
Keys support hierarchical paths (e.g., `app/env/secret_name`), which map to isolated JSON files under `${SECRETS_DIR}` with `0700` directory permissions and `0600` file permissions:

```text
.secrets.d/
├── payments-api/
│   ├── dev/jwt.json
│   └── prod/jwt.json
└── vault/
    └── staging/token.json
```

---

## Function Signatures & Descriptions

### `cache_init`

* **Signature:** `cache_init [dir]`
* **Description:** Initializes the secrets cache directory (`SECRETS_DIR` or a custom path) with owner-only (`0700`) permissions.

#### Example Code:
```zsh
cache_init
# Or override with a custom directory:
cache_init "${HOME}/.my_secrets.d"
```

---
### `cache_set`

* **Signature:** `cache_set <key> <value> [ttl_seconds]`
* **Description:** Stores a secret or token under `<key>` with an optional TTL in seconds (`0` = persistent). If `ttl_seconds` is omitted and `<value>` is a JWT with an `exp` claim, the expiration timestamp is automatically extracted from the JWT.

#### Example Code:
```zsh
# Store an API key for 1 hour (3600s)
cache_set "payments-api/prod/api_key" "sk_live_abc123" 3600

# Store a JWT and auto-detect its 'exp' claim
cache_set "payments-api/prod/jwt" "${jwt_token}"

# Store a persistent secret (no expiry)
cache_set "payments-api/dev/client_id" "client-xyz" 0
```

---
### `cache_get`

* **Signature:** `cache_get <key>`
* **Description:** Retrieves a valid, non-expired secret value and prints it to stdout. If the entry is missing or expired (including expired JWTs), removes the expired entry and returns `1`.

#### Example Code:
```zsh
if token=$(cache_get "payments-api/prod/jwt"); then
  echo "Reusing cached token"
else
  echo "Cache miss or expired; logging in..."
fi
```

---
### `cache_has`

* **Signature:** `cache_has <key>`
* **Description:** Checks whether a valid, non-expired secret exists for `<key>`. Returns `0` if valid, `1` if missing or expired.

#### Example Code:
```zsh
if cache_has "payments-api/prod/jwt"; then
  echo "Token is cached and valid"
fi
```

---
### `cache_ttl`

* **Signature:** `cache_ttl <key>`
* **Description:** Prints the remaining TTL in seconds for `<key>` (`0` if persistent / no expiry). Returns `1` if missing or expired.

#### Example Code:
```zsh
remaining=$(cache_ttl "payments-api/prod/jwt")
echo "Token expires in ${remaining}s"
```

---
### `cache_remove`

* **Signature:** `cache_remove <key>`
* **Description:** Removes a cached secret entry and cleans up any resulting empty subdirectories under `SECRETS_DIR`.

#### Example Code:
```zsh
cache_remove "payments-api/prod/jwt"
```

---
### `cache_clear`

* **Signature:** `cache_clear [prefix]`
* **Description:** Clears all cached secrets under `SECRETS_DIR`, or only those under a specific app/environment prefix.

#### Example Code:
```zsh
# Clear only staging secrets for payments-api
cache_clear "payments-api/staging"

# Clear all cached secrets
cache_clear
```

---
### `cache_prune`

* **Signature:** `cache_prune`
* **Description:** Scans `SECRETS_DIR`, removes all expired entries and empty subdirectories, and prints the number of pruned entries.

#### Example Code:
```zsh
pruned=$(cache_prune)
echo "Pruned ${pruned} expired secrets"
```

---
### `cache_list`

* **Signature:** `cache_list [prefix]`
* **Description:** Lists cached secret keys and their expiry status (`valid (<N>s remaining)`, `persistent`, or `expired`) without ever printing secret values.

#### Example Code:
```zsh
cache_list "payments-api"
```

---
### `cache_get_or_set`

* **Signature:** `cache_get_or_set <key> <ttl_seconds> <command...>`
* **Description:** Returns the cached secret if valid; otherwise executes `<command...>`, caches its stdout under `<key>` with `<ttl_seconds>`, and prints the fresh secret. Ideal for avoiding redundant login calls.

#### Example Code:
```zsh
login_to_api() {
  # Simulate expensive login call
  echo "fresh-jwt-token"
}

# Only calls login_to_api on cache miss or expiration
token=$(cache_get_or_set "payments-api/prod/jwt" 3600 login_to_api)
```

---

## Per-Function Copy-Paste Reference

Browse dedicated per-function pages with all flags and copy-paste variations in [`docs/19-cache/`](19-cache/README.md), or run [`examples/19_cache_example.sh`](../examples/19_cache_example.sh).

| Function | Per-Function Docs & Flags | Runnable Example |
| :--- | :--- | :--- |
| `cache_init` | [Docs & Examples](19-cache/cache_init.md) | [`19_cache_example.sh`](../examples/19_cache_example.sh) |
| `cache_set` | [Docs & Examples](19-cache/cache_set.md) | [`19_cache_example.sh`](../examples/19_cache_example.sh) |
| `cache_get` | [Docs & Examples](19-cache/cache_get.md) | [`19_cache_example.sh`](../examples/19_cache_example.sh) |
| `cache_has` | [Docs & Examples](19-cache/cache_has.md) | [`19_cache_example.sh`](../examples/19_cache_example.sh) |
| `cache_ttl` | [Docs & Examples](19-cache/cache_ttl.md) | [`19_cache_example.sh`](../examples/19_cache_example.sh) |
| `cache_remove` | [Docs & Examples](19-cache/cache_remove.md) | [`19_cache_example.sh`](../examples/19_cache_example.sh) |
| `cache_clear` | [Docs & Examples](19-cache/cache_clear.md) | [`19_cache_example.sh`](../examples/19_cache_example.sh) |
| `cache_prune` | [Docs & Examples](19-cache/cache_prune.md) | [`19_cache_example.sh`](../examples/19_cache_example.sh) |
| `cache_list` | [Docs & Examples](19-cache/cache_list.md) | [`19_cache_example.sh`](../examples/19_cache_example.sh) |
| `cache_get_or_set` | [Docs & Examples](19-cache/cache_get_or_set.md) | [`19_cache_example.sh`](../examples/19_cache_example.sh) |