# `json_to_yaml`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../14-jq.md) › [Function Index](README.md) › **`json_to_yaml`** › [Runnable Example](../../examples/14_jq_example.sh) › [Tests](../../tests/14-jq.test.sh)

- **Source:** [`functions/14-jq.sh#L139-L153`](../../functions/14-jq.sh#L139-L153)
- **Signature:** `json_to_yaml <json>`
- **Description:** Converts a JSON string to YAML format.

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

- {string} YAML format output.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  json_to_yaml '{"name": "Bob", "age": 30}'
```

---

See also the full runnable example script: [`examples/14_jq_example.sh`](../../examples/14_jq_example.sh).
