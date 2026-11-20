# `http_unset_default_header`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../06-http.md) › [Function Index](README.md) › **`http_unset_default_header`** › [Runnable Example](../../examples/06_http_example.sh) › [Tests](../../tests/06-http.test.sh)

- **Source:** [`functions/06-http.sh#L121-L127`](../../functions/06-http.sh#L121-L127)
- **Signature:** `http_unset_default_header <name>`
- **Description:** Removes a default HTTP header from HTTP_DEFAULT_HEADERS (case-insensitive lookup).

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `name` (`string`) | Header name to remove. |

## Return / Exit Value

- {number} 0 on success, or 1 if name is empty.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  http_unset_default_header "X-Vault-Token"
```

---

See also the full runnable example script: [`examples/06_http_example.sh`](../../examples/06_http_example.sh).
