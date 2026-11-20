# `mask_phone`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../16-mask.md) › [Function Index](README.md) › **`mask_phone`** › [Runnable Example](../../examples/16_mask_example.sh) › [Tests](../../tests/16-mask.test.sh)

- **Source:** [`functions/16-mask.sh#L147-L149`](../../functions/16-mask.sh#L147-L149)
- **Signature:** `mask_phone <phone> [visible_digits=4] [mask_char="*"]`
- **Description:** Masks all digits in a phone number except the last N digits, preserving formatting characters.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `phone` (`string`) | The phone number to mask. |
| `[visible_digits=4]` (`number`) | Number of trailing digits to keep visible. |
| `[mask_char="*"]` (`string`) | Character used for masking. |

## Return / Exit Value

- {string} The masked phone number.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  mask_phone "+1-555-123-4567" 4
```

---

See also the full runnable example script: [`examples/16_mask_example.sh`](../../examples/16_mask_example.sh).
