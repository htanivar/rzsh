# `mask_string`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../16-mask.md) › [Function Index](README.md) › **`mask_string`** › [Runnable Example](../../examples/16_mask_example.sh) › [Tests](../../tests/16-mask.test.sh)

- **Source:** [`functions/16-mask.sh#L62-L88`](../../functions/16-mask.sh#L62-L88)
- **Signature:** `mask_string <str> [visible_start=2] [visible_end=2] [mask_char="*"]`
- **Description:** Masks the middle portion of a string, keeping a specified number of leading and trailing characters visible.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `str` (`string`) | The input string to mask. |
| `[visible_start=2]` (`number`) | Number of leading characters to keep visible. |
| `[visible_end=2]` (`number`) | Number of trailing characters to keep visible. |
| `[mask_char="*"]` (`string`) | Character used for masking. |

## Return / Exit Value

- {string} The masked string.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  mask_string "my-secret-value" 2 2
```

---

See also the full runnable example script: [`examples/16_mask_example.sh`](../../examples/16_mask_example.sh).
