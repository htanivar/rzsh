# `mock_array`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../17-mock.md) › [Function Index](README.md) › **`mock_array`** › [Runnable Example](../../examples/17_mock_example.sh) › [Tests](../../tests/17-mock.test.sh)

- **Source:** [`functions/17-mock.sh#L327-L344`](../../functions/17-mock.sh#L327-L344)
- **Signature:** `mock_array [count=5] [array_name=MOCK_ARRAY] [item_type="string"]`
- **Description:** Populates a Zsh array variable with N dummy items of a given type.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `[count=5]` (`number`) | Number of elements to generate. |
| `[array_name=MOCK_ARRAY]` (`string`) | Target Zsh array variable name. |
| `[item_type="string"]` (`string`) | Item generator type: string, alphanumeric, int, bool, email, uuid, token, password. |

## Return / Exit Value

- {number} 0 on success, 1 if array_name is invalid.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local -a users
  mock_array 3 "users" "email"
```

---

See also the full runnable example script: [`examples/17_mock_example.sh`](../../examples/17_mock_example.sh).
