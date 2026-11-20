# `http_get_default_header`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../06-http.md) › [Function Index](README.md) › **`http_get_default_header`** › [Runnable Example](../../examples/06_http_example.sh) › [Tests](../../tests/06-http.test.sh)

- **Source:** [`functions/06-http.sh#L95-L111`](../../functions/06-http.sh#L95-L111)
- **Signature:** `http_get_default_header <name>`
- **Description:** Retrieves a default HTTP header value from HTTP_DEFAULT_HEADERS (case-insensitive lookup).

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `name` (`string`) | Header name to look up. |

## Return / Exit Value

- {string} The header value, or empty if not set.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local ct
  ct=$(http_get_default_header "Content-Type")
```

---

See also the full runnable example script: [`examples/06_http_example.sh`](../../examples/06_http_example.sh).
