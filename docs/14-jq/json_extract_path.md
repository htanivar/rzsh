# `json_extract_path`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../14-jq.md) › [Function Index](README.md) › **`json_extract_path`** › [Runnable Example](../../examples/14_jq_example.sh) › [Tests](../../tests/14-jq.test.sh)

- **Source:** [`functions/14-jq.sh#L260-L262`](../../functions/14-jq.sh#L260-L262)
- **Signature:** `json_extract_path <json> <path>`
- **Description:** Alias to json_get_value. Retrieves a value from a JSON path.

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
| `path` (`string`) | jq path. |

## Return / Exit Value

- {string} Value at path.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  json_extract_path '{"id": 1}' '.id'
```

---

See also the full runnable example script: [`examples/14_jq_example.sh`](../../examples/14_jq_example.sh).
