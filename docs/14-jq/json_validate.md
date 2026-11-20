# `json_validate`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../14-jq.md) › [Function Index](README.md) › **`json_validate`** › [Runnable Example](../../examples/14_jq_example.sh) › [Tests](../../tests/14-jq.test.sh)

- **Source:** [`functions/14-jq.sh#L165-L171`](../../functions/14-jq.sh#L165-L171)
- **Signature:** `json_validate <json>`
- **Description:** Validates if a string is a syntactically correct JSON document.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `json` (`string`) | JSON string to validate. |

## Return / Exit Value

- {number} 0 if valid JSON, 1 otherwise.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  if json_validate "${some_input}"; then
    echo "JSON is valid"
  fi
```

---

See also the full runnable example script: [`examples/14_jq_example.sh`](../../examples/14_jq_example.sh).
