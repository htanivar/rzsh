# `http_build_headers`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../06-http.md) › [Function Index](README.md) › **`http_build_headers`** › [Runnable Example](../../examples/06_http_example.sh) › [Tests](../../tests/06-http.test.sh)

- **Source:** [`functions/06-http.sh#L152-L167`](../../functions/06-http.sh#L152-L167)
- **Signature:** `http_build_headers [headers...]`
- **Description:** Builds a newline-separated HTTP headers string by merging HTTP_DEFAULT_HEADERS with any extra/override headers passed as arguments.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `[headers...]` (`string`) | Optional header strings ("Key: Value") or newline-separated header blocks that override matching default headers. |

## Return / Exit Value

- {string} Newline-separated "Key: Value" headers ready for http_* functions.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local hdrs
  hdrs=$(http_build_headers "X-Custom: 1" "Accept: text/plain")
```

---

See also the full runnable example script: [`examples/06_http_example.sh`](../../examples/06_http_example.sh).
