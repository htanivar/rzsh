# `json_array_remove`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../14-jq.md) › [Function Index](README.md) › **`json_array_remove`** › [Runnable Example](../../examples/14_jq_example.sh) › [Tests](../../tests/14-jq.test.sh)

- **Source:** [`functions/14-jq.sh#L241-L249`](../../functions/14-jq.sh#L241-L249)
- **Signature:** `json_array_remove <json> <path> <index>`
- **Description:** Removes an item from a JSON array by its index.

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
| `path` (`string`) | jq path to array. |
| `index` (`number`) | Index of element to delete. |

## Return / Exit Value

- {string} Modified JSON.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  json_array_remove '{"tags": ["a", "b"]}' '.tags' 0
```

---

See also the full runnable example script: [`examples/14_jq_example.sh`](../../examples/14_jq_example.sh).
