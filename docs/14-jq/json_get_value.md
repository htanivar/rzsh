# `json_get_value`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../14-jq.md) › [Function Index](README.md) › **`json_get_value`** › [Runnable Example](../../examples/14_jq_example.sh) › [Tests](../../tests/14-jq.test.sh)

- **Source:** [`functions/14-jq.sh#L40-L47`](../../functions/14-jq.sh#L40-L47)
- **Signature:** `json_get_value <json> <path>`
- **Description:** Gets the value at the specified JSON path using jq.

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
| `path` (`string`) | jq path filter (e.g. '.user.name'). |

## Return / Exit Value

- {string} The extracted value.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local name
  name=$(json_get_value '{"user": {"name": "Bob"}}' '.user.name')
```

---

See also the full runnable example script: [`examples/14_jq_example.sh`](../../examples/14_jq_example.sh).
