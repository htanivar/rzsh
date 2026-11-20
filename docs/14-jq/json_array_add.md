# `json_array_add`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../14-jq.md) › [Function Index](README.md) › **`json_array_add`** › [Runnable Example](../../examples/14_jq_example.sh) › [Tests](../../tests/14-jq.test.sh)

- **Source:** [`functions/14-jq.sh#L215-L229`](../../functions/14-jq.sh#L215-L229)
- **Signature:** `json_array_add <json> <path> <item>`
- **Description:** Appends an item to a JSON array at the specified path.

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
| `path` (`string`) | jq path to array (e.g. '.tags'). |
| `item` (`string`) | The value to append. |

## Return / Exit Value

- {string} Modified JSON.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  json_array_add '{"tags": ["a"]}' '.tags' '"b"'
```

---

See also the full runnable example script: [`examples/14_jq_example.sh`](../../examples/14_jq_example.sh).
