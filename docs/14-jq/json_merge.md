# `json_merge`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../14-jq.md) › [Function Index](README.md) › **`json_merge`** › [Runnable Example](../../examples/14_jq_example.sh) › [Tests](../../tests/14-jq.test.sh)

- **Source:** [`functions/14-jq.sh#L122-L129`](../../functions/14-jq.sh#L122-L129)
- **Signature:** `json_merge <json1> <json2>`
- **Description:** Merges two JSON objects together.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `json1` (`string`) | First JSON object. |
| `json2` (`string`) | Second JSON object. |

## Return / Exit Value

- {string} Merged JSON.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  json_merge '{"a": 1}' '{"b": 2}'
```

---

See also the full runnable example script: [`examples/14_jq_example.sh`](../../examples/14_jq_example.sh).
