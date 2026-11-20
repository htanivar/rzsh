# `mock_alphanumeric`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../17-mock.md) › [Function Index](README.md) › **`mock_alphanumeric`** › [Runnable Example](../../examples/17_mock_example.sh) › [Tests](../../tests/17-mock.test.sh)

- **Source:** [`functions/17-mock.sh#L115-L118`](../../functions/17-mock.sh#L115-L118)
- **Signature:** `mock_alphanumeric [length=16]`
- **Description:** Generates a random alphanumeric (A-Z, a-z, 0-9) dummy string.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `[length=16]` (`number`) | Length of the generated string. |

## Return / Exit Value

- {string} The generated alphanumeric string.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  id=$(mock_alphanumeric 16)
```

---

See also the full runnable example script: [`examples/17_mock_example.sh`](../../examples/17_mock_example.sh).
