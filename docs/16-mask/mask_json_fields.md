# `mask_json_fields`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../16-mask.md) › [Function Index](README.md) › **`mask_json_fields`** › [Runnable Example](../../examples/16_mask_example.sh) › [Tests](../../tests/16-mask.test.sh)

- **Source:** [`functions/16-mask.sh#L175-L194`](../../functions/16-mask.sh#L175-L194)
- **Signature:** `mask_json_fields <json_str> <fields_csv> [mask_value="***MASKED***"]`
- **Description:** Masks specified sensitive fields (recursively) in a JSON string using jq.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `json_str` (`string`) | The input JSON string. |
| `fields_csv` (`string`) | Comma-separated list of JSON field names to mask (e.g., "password,token,secret"). |
| `[mask_value="***MASKED***"]` (`string`) | Replacement value for masked fields. |

## Return / Exit Value

- {string} JSON string with specified fields masked, or 1 if jq is unavailable or JSON is invalid.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  mask_json_fields '{"user":"alice","token":"abc123"}' "token,password"
```

---

See also the full runnable example script: [`examples/16_mask_example.sh`](../../examples/16_mask_example.sh).
