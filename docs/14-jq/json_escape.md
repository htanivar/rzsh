# `json_escape`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../14-jq.md) › [Function Index](README.md) › **`json_escape`** › [Runnable Example](../../examples/14_jq_example.sh) › [Tests](../../tests/14-jq.test.sh)

- **Source:** [`functions/14-jq.sh#L197-L203`](../../functions/14-jq.sh#L197-L203)
- **Signature:** `json_escape <json>`
- **Description:** Escapes a JSON string so it can be safely used in a string field.

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

## Return / Exit Value

- {string} Escaped JSON.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  json_escape '{"name": "Bob"}'
```

---

See also the full runnable example script: [`examples/14_jq_example.sh`](../../examples/14_jq_example.sh).
