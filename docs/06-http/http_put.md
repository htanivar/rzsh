# `http_put`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../06-http.md) › [Function Index](README.md) › **`http_put`** › [Runnable Example](../../examples/06_http_example.sh) › [Tests](../../tests/06-http.test.sh)

- **Source:** [`functions/06-http.sh#L255-L257`](../../functions/06-http.sh#L255-L257)
- **Signature:** `http_put <url> <data> [headers]`
- **Description:** Performs an HTTP PUT request using curl. Supports passing a JSON string, a path to a .json file, or @file.json. Appends HTTP status code to the last line of the output.

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
| `data` (`string`) | The PUT request body data (inline JSON string, file path to .json file, or @file.json). |
| `[headers]` (`string`) | Newline-separated headers to include (merged with HTTP_DEFAULT_HEADERS). |

## Return / Exit Value

- {string} Response body followed by a newline and the HTTP status code.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local res
  res=$(http_put "https://httpbin.org/put" "./payload.json" "Content-Type: application/json")
```

---

See also the full runnable example script: [`examples/06_http_example.sh`](../../examples/06_http_example.sh).
