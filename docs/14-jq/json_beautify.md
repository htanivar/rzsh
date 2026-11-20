# `json_beautify`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../14-jq.md) › [Function Index](README.md) › **`json_beautify`** › [Runnable Example](../../examples/14_jq_example.sh) › [Tests](../../tests/14-jq.test.sh)

- **Source:** [`functions/14-jq.sh#L181-L187`](../../functions/14-jq.sh#L181-L187)
- **Signature:** `json_beautify <json>`
- **Description:** Formats a JSON string with pretty spacing/indentation.

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

- {string} Formatted JSON.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  json_beautify '{"a":1}'
```

---

See also the full runnable example script: [`examples/14_jq_example.sh`](../../examples/14_jq_example.sh).
