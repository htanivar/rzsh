# `json_get_keys`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../14-jq.md) › [Function Index](README.md) › **`json_get_keys`** › [Runnable Example](../../examples/14_jq_example.sh) › [Tests](../../tests/14-jq.test.sh)

- **Source:** [`functions/14-jq.sh#L104-L111`](../../functions/14-jq.sh#L104-L111)
- **Signature:** `json_get_keys <json> [path="."]`
- **Description:** Gets all keys at the specified JSON path.

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
| `[path="."]` (`string`) | jq path filter. |

## Return / Exit Value

- {string} JSON array of keys.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  json_get_keys '{"name": "Bob", "age": 30}'
```

---

See also the full runnable example script: [`examples/14_jq_example.sh`](../../examples/14_jq_example.sh).
