# `mask_email`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../16-mask.md) › [Function Index](README.md) › **`mask_email`** › [Runnable Example](../../examples/16_mask_example.sh) › [Tests](../../tests/16-mask.test.sh)

- **Source:** [`functions/16-mask.sh#L116-L135`](../../functions/16-mask.sh#L116-L135)
- **Signature:** `mask_email <email> [mask_char="*"]`
- **Description:** Masks the local part of an email address while preserving the first character and domain.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `email` (`string`) | The email address to mask. |
| `[mask_char="*"]` (`string`) | Character used for masking. |

## Return / Exit Value

- {string} The masked email address.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  mask_email "alice.smith@example.com"
```

---

See also the full runnable example script: [`examples/16_mask_example.sh`](../../examples/16_mask_example.sh).
