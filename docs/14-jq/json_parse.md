# `json_parse`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../14-jq.md) › [Function Index](README.md) › **`json_parse`** › [Runnable Example](../../examples/14_jq_example.sh) › [Tests](../../tests/14-jq.test.sh)

- **Source:** [`functions/14-jq.sh#L22-L28`](../../functions/14-jq.sh#L22-L28)
- **Signature:** `json_parse <json>`
- **Description:** Parses and prints the structured representation of a JSON string.

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

- {number} 0 on success, non-zero on failure.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  json_parse '{"name": "test"}'
```

---

See also the full runnable example script: [`examples/14_jq_example.sh`](../../examples/14_jq_example.sh).
