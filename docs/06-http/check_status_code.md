# `check_status_code`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../06-http.md) › [Function Index](README.md) › **`check_status_code`** › [Runnable Example](../../examples/06_http_example.sh) › [Tests](../../tests/06-http.test.sh)

- **Source:** [`functions/06-http.sh#L297-L300`](../../functions/06-http.sh#L297-L300)
- **Signature:** `check_status_code <response>`
- **Description:** Extracts the HTTP status code from the formatted curl response output.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `response` (`string`) | The raw HTTP response (containing status code on last line). |

## Return / Exit Value

- {string} The HTTP status code.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local code
  code=$(check_status_code "${res}")
```

---

See also the full runnable example script: [`examples/06_http_example.sh`](../../examples/06_http_example.sh).
