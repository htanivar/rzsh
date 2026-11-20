# `http_delete`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../06-http.md) › [Function Index](README.md) › **`http_delete`** › [Runnable Example](../../examples/06_http_example.sh) › [Tests](../../tests/06-http.test.sh)

- **Source:** [`functions/06-http.sh#L284-L286`](../../functions/06-http.sh#L284-L286)
- **Signature:** `http_delete <url> [headers]`
- **Description:** Performs an HTTP DELETE request using curl. Appends HTTP status code to the last line of the output.

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
| `[headers]` (`string`) | Newline-separated headers to include (merged with HTTP_DEFAULT_HEADERS). |

## Return / Exit Value

- {string} Response body followed by a newline and the HTTP status code.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local res
  res=$(http_delete "https://httpbin.org/delete")
```

---

See also the full runnable example script: [`examples/06_http_example.sh`](../../examples/06_http_example.sh).
