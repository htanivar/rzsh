# `mock_password`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../17-mock.md) › [Function Index](README.md) › **`mock_password`** › [Runnable Example](../../examples/17_mock_example.sh) › [Tests](../../tests/17-mock.test.sh)

- **Source:** [`functions/17-mock.sh#L129-L164`](../../functions/17-mock.sh#L129-L164)
- **Signature:** `mock_password [length=16] [include_special=1]`
- **Description:** Generates a random password with uppercase, lowercase, digits, and optional special characters.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `[length=16]` (`number`) | Password length (minimum 4 enforced when length >= 4). |
| `[include_special=1]` (`number`) | Set to 1 to include special characters (!@#$%^&*-_=+), or 0 for alphanumeric only. |

## Return / Exit Value

- {string} The generated password.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  pw=$(mock_password 16 1)
```

---

See also the full runnable example script: [`examples/17_mock_example.sh`](../../examples/17_mock_example.sh).
