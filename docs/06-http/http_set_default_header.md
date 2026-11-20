# `http_set_default_header`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../06-http.md) › [Function Index](README.md) › **`http_set_default_header`** › [Runnable Example](../../examples/06_http_example.sh) › [Tests](../../tests/06-http.test.sh)

- **Source:** [`functions/06-http.sh#L57-L84`](../../functions/06-http.sh#L57-L84)
- **Signature:** `http_set_default_header <name> <value>`
- **Description:** Sets or updates a default HTTP header in HTTP_DEFAULT_HEADERS (case-insensitive key replacement). Passing an empty value unsets the header.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `name` (`string`) | Header name (e.g., "Authorization", "X-Vault-Request"). |
| `value` (`string`) | Header value (e.g., "Bearer token", "true"). |

## Return / Exit Value

- {number} 0 on success, or 1 if name is empty.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  http_set_default_header "Authorization" "Bearer my-token"
```

---

See also the full runnable example script: [`examples/06_http_example.sh`](../../examples/06_http_example.sh).
