# `mask_token`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../16-mask.md) › [Function Index](README.md) › **`mask_token`** › [Runnable Example](../../examples/16_mask_example.sh) › [Tests](../../tests/16-mask.test.sh)

- **Source:** [`functions/16-mask.sh#L100-L105`](../../functions/16-mask.sh#L100-L105)
- **Signature:** `mask_token <token> [visible_chars=4] [mask_char="*"]`
- **Description:** Masks an API token, Bearer secret, or key, keeping only the first and last N characters visible.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `token` (`string`) | The token or secret string to mask. |
| `[visible_chars=4]` (`number`) | Number of characters to keep visible at each end. |
| `[mask_char="*"]` (`string`) | Character used for masking. |

## Return / Exit Value

- {string} The masked token.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  mask_token "hvs.CAESIJ1234567890abcdef" 4
```

---

See also the full runnable example script: [`examples/16_mask_example.sh`](../../examples/16_mask_example.sh).
