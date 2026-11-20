# `validate_url`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../04-validation.md) › [Function Index](README.md) › **`validate_url`** › [Runnable Example](../../examples/04_validation_example.sh) › [Tests](../../tests/04-validation.test.sh)

- **Source:** [`functions/04-validation.sh#L133-L139`](../../functions/04-validation.sh#L133-L139)
- **Signature:** `validate_url <url>`
- **Description:** Validates that a string is a valid HTTP/HTTPS URL.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `url` (`string`) | The URL to validate. |

## Return / Exit Value

- {number} 0 if valid, 1 otherwise.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  validate_url "https://google.com"
```

---

See also the full runnable example script: [`examples/04_validation_example.sh`](../../examples/04_validation_example.sh).
