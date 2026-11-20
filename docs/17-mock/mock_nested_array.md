# `mock_nested_array`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../17-mock.md) › [Function Index](README.md) › **`mock_nested_array`** › [Runnable Example](../../examples/17_mock_example.sh) › [Tests](../../tests/17-mock.test.sh)

- **Source:** [`functions/17-mock.sh#L356-L379`](../../functions/17-mock.sh#L356-L379)
- **Signature:** `mock_nested_array [rows=3] [cols=3] [item_type="string"]`
- **Description:** Generates a JSON 2D nested array with the specified rows, columns, and element type.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `[rows=3]` (`number`) | Number of outer array rows. |
| `[cols=3]` (`number`) | Number of elements per inner array. |
| `[item_type="string"]` (`string`) | Element type: string, alphanumeric, int, bool, email, uuid. |

## Return / Exit Value

- {string} Compact JSON 2D array string.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  matrix=$(mock_nested_array 2 3 "int")
```

---

See also the full runnable example script: [`examples/17_mock_example.sh`](../../examples/17_mock_example.sh).
