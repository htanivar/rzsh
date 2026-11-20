# `http_get_body`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../06-http.md) › [Function Index](README.md) › **`http_get_body`** › [Runnable Example](../../examples/06_http_example.sh) › [Tests](../../tests/06-http.test.sh)

- **Source:** [`functions/06-http.sh#L311-L314`](../../functions/06-http.sh#L311-L314)
- **Signature:** `http_get_body <response>`
- **Description:** Extracts the HTTP response body from a raw HTTP response (excluding the trailing status code).

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `response` (`string`) | The raw response string containing response body followed by status code. |

## Return / Exit Value

- {string} The response body.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local body
  body=$(http_get_body "${res}")
```

---

See also the full runnable example script: [`examples/06_http_example.sh`](../../examples/06_http_example.sh).
