# `extract_json_field`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../06-http.md) › [Function Index](README.md) › **`extract_json_field`** › [Runnable Example](../../examples/06_http_example.sh) › [Tests](../../tests/06-http.test.sh)

- **Source:** [`functions/06-http.sh#L343-L351`](../../functions/06-http.sh#L343-L351)
- **Signature:** `extract_json_field <json> <field>`
- **Description:** Extracts a specific field from a JSON string using jq.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `json` (`string`) | The JSON string. |
| `field` (`string`) | The field query path (e.g. '.name' or '.nested.value'). |

## Return / Exit Value

- {string} The extracted value.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local val
  val=$(extract_json_field '{"user": "Alice"}' ".user")
```

---

See also the full runnable example script: [`examples/06_http_example.sh`](../../examples/06_http_example.sh).
