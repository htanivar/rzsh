# `is_json_response`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../06-http.md) › [Function Index](README.md) › **`is_json_response`** › [Runnable Example](../../examples/06_http_example.sh) › [Tests](../../tests/06-http.test.sh)

- **Source:** [`functions/06-http.sh#L326-L331`](../../functions/06-http.sh#L326-L331)
- **Signature:** `is_json_response <response>`
- **Description:** Checks if the response body (excluding status code) is valid JSON.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `response` (`string`) | The raw response output. |

## Return / Exit Value

- {number} 0 if JSON, 1 otherwise.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  if is_json_response "${res}"; then
    echo "Received JSON response"
  fi
```

---

See also the full runnable example script: [`examples/06_http_example.sh`](../../examples/06_http_example.sh).
