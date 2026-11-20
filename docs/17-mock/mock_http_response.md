# `mock_http_response`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../17-mock.md) › [Function Index](README.md) › **`mock_http_response`** › [Runnable Example](../../examples/17_mock_example.sh) › [Tests](../../tests/17-mock.test.sh)

- **Source:** [`functions/17-mock.sh#L486-L490`](../../functions/17-mock.sh#L486-L490)
- **Signature:** `mock_http_response [body='{"ok":true}'] [status_code=200]`
- **Description:** Convenience helper that mocks curl to return a specified body and HTTP status code for 06-http.sh calls.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `[body='{"ok":true}']` (`string`) | Response body to return. |
| `[status_code=200]` (`number`) | HTTP status code appended on the final line. |

## Return / Exit Value

- {number} 0 on success.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  mock_http_response '{"status":"healthy"}' 200
```

---

See also the full runnable example script: [`examples/17_mock_example.sh`](../../examples/17_mock_example.sh).
