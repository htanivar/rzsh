# `http_get_with_retry`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../06-http.md) › [Function Index](README.md) › **`http_get_with_retry`** › [Runnable Example](../../examples/06_http_example.sh) › [Tests](../../tests/06-http.test.sh)

- **Source:** [`functions/06-http.sh#L381-L401`](../../functions/06-http.sh#L381-L401)
- **Signature:** `http_get_with_retry <url> [retries=3]`
- **Description:** Performs an HTTP GET request with retries if the status code is not 2xx.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `url` (`string`) | The URL to request. |
| `[retries=3]` (`number`) | Maximum number of attempts. |

## Return / Exit Value

- {string} Response body followed by a newline and the HTTP status code.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local res
  res=$(http_get_with_retry "https://api.github.com" 5)
```

---

See also the full runnable example script: [`examples/06_http_example.sh`](../../examples/06_http_example.sh).
