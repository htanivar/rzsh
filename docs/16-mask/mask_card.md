# `mask_card`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../16-mask.md) › [Function Index](README.md) › **`mask_card`** › [Runnable Example](../../examples/16_mask_example.sh) › [Tests](../../tests/16-mask.test.sh)

- **Source:** [`functions/16-mask.sh#L161-L163`](../../functions/16-mask.sh#L161-L163)
- **Signature:** `mask_card <card_number> [visible_digits=4] [mask_char="*"]`
- **Description:** Masks a payment card number, keeping only the last N digits visible while preserving separators.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `card_number` (`string`) | The card number to mask. |
| `[visible_digits=4]` (`number`) | Number of trailing digits to keep visible. |
| `[mask_char="*"]` (`string`) | Character used for masking. |

## Return / Exit Value

- {string} The masked card number.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  mask_card "4111-1111-1111-1234" 4
```

---

See also the full runnable example script: [`examples/16_mask_example.sh`](../../examples/16_mask_example.sh).
