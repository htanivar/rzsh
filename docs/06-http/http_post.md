# `http_post`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../06-http.md) › [Function Index](README.md) › **`http_post`** › [Runnable Example](../../examples/06_http_example.sh) › [Tests](../../tests/06-http.test.sh)

- **Source:** [`functions/06-http.sh#L240-L242`](../../functions/06-http.sh#L240-L242)
- **Signature:** `http_post <url> <data> [headers]`
- **Description:** Performs an HTTP POST request using curl. Supports passing a JSON string, a path to a .json file, or @file.json. Appends HTTP status code to the last line of the output.

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
| `data` (`string`) | The POST request body data (inline JSON string, file path to .json file, or @file.json). |
| `[headers]` (`string`) | Newline-separated headers to include (merged with HTTP_DEFAULT_HEADERS). |

## Return / Exit Value

- {string} Response body followed by a newline and the HTTP status code.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local res
  res=$(http_post "https://httpbin.org/post" "./payload.json" "Content-Type: application/json")
```

### 2. Inline JSON, file path, @file, and JSON+override

```zsh
http_post "https://api.example.com/items" '{"name":"widget"}'
http_post "https://api.example.com/items" "./payload.json"
http_post "https://api.example.com/items" "@./payload.json" "X-Env: staging"
```

---

See also the full runnable example script: [`examples/06_http_example.sh`](../../examples/06_http_example.sh).
