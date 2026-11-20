# `json_delete_key`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../14-jq.md) › [Function Index](README.md) › **`json_delete_key`** › [Runnable Example](../../examples/14_jq_example.sh) › [Tests](../../tests/14-jq.test.sh)

- **Source:** [`functions/14-jq.sh#L86-L93`](../../functions/14-jq.sh#L86-L93)
- **Signature:** `json_delete_key <json> <path>`
- **Description:** Deletes a key/field at the specified JSON path.

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
| `path` (`string`) | jq path filter to delete (e.g. '.user.secret'). |

## Return / Exit Value

- {string} The modified JSON.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local cleaned
  cleaned=$(json_delete_key '{"name": "Bob", "secret": "123"}' '.secret')
```

---

See also the full runnable example script: [`examples/14_jq_example.sh`](../../examples/14_jq_example.sh).
