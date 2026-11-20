# `mock_string`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../17-mock.md) › [Function Index](README.md) › **`mock_string`** › [Runnable Example](../../examples/17_mock_example.sh) › [Tests](../../tests/17-mock.test.sh)

- **Source:** [`functions/17-mock.sh#L101-L105`](../../functions/17-mock.sh#L101-L105)
- **Signature:** `mock_string [length=12] [prefix=""]`
- **Description:** Generates a random alphabetic dummy string, optionally with a prefix.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `[length=12]` (`number`) | Number of random alphabetic characters. |
| `[prefix=""]` (`string`) | Optional string prefix. |

## Return / Exit Value

- {string} The generated dummy string.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  val=$(mock_string 8 "user_")
```

---

See also the full runnable example script: [`examples/17_mock_example.sh`](../../examples/17_mock_example.sh).
