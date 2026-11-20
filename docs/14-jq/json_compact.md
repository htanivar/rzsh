# `json_compact`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../14-jq.md) › [Function Index](README.md) › **`json_compact`** › [Runnable Example](../../examples/14_jq_example.sh) › [Tests](../../tests/14-jq.test.sh)

- **Source:** [`functions/14-jq.sh#L272-L278`](../../functions/14-jq.sh#L272-L278)
- **Signature:** `json_compact <json>`
- **Description:** Compacts a JSON string, removing all non-essential formatting whitespace.

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

- {string} Compacted JSON.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  json_compact '{\n  "a": 1\n}'
```

---

See also the full runnable example script: [`examples/14_jq_example.sh`](../../examples/14_jq_example.sh).
