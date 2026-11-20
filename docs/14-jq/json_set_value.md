# `json_set_value`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../14-jq.md) › [Function Index](README.md) › **`json_set_value`** › [Runnable Example](../../examples/14_jq_example.sh) › [Tests](../../tests/14-jq.test.sh)

- **Source:** [`functions/14-jq.sh#L60-L74`](../../functions/14-jq.sh#L60-L74)
- **Signature:** `json_set_value <json> <path> <value>`
- **Description:** Modifies/adds a value at the specified JSON path.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `json` (`string`) | JSON string. |
| `path` (`string`) | jq path filter (e.g. '.user.age'). |
| `value` (`string`) | New value to set. |

## Return / Exit Value

- {string} The modified JSON.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local new_json
  new_json=$(json_set_value '{"name": "Bob"}' '.age' '30')
```

---

See also the full runnable example script: [`examples/14_jq_example.sh`](../../examples/14_jq_example.sh).
