# `mock_json`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../17-mock.md) › [Function Index](README.md) › **`mock_json`** › [Runnable Example](../../examples/17_mock_example.sh) › [Tests](../../tests/17-mock.test.sh)

- **Source:** [`functions/17-mock.sh#L390-L413`](../../functions/17-mock.sh#L390-L413)
- **Signature:** `mock_json [depth=1] [keys_count=3]`
- **Description:** Generates a dummy JSON object with optional nested objects and nested arrays.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `[depth=1]` (`number`) | Nesting depth (1 = flat object, 2+ = includes nested object and nested array). |
| `[keys_count=3]` (`number`) | Number of scalar keys at the root level. |

## Return / Exit Value

- {string} Valid JSON object string.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  payload=$(mock_json 2 3)
```

---

See also the full runnable example script: [`examples/17_mock_example.sh`](../../examples/17_mock_example.sh).
