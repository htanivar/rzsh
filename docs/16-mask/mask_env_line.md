# `mask_env_line`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../16-mask.md) › [Function Index](README.md) › **`mask_env_line`** › [Runnable Example](../../examples/16_mask_example.sh) › [Tests](../../tests/16-mask.test.sh)

- **Source:** [`functions/16-mask.sh#L206-L239`](../../functions/16-mask.sh#L206-L239)
- **Signature:** `mask_env_line <line> [sensitive_keys_csv="PASSWORD,SECRET,TOKEN,KEY,AUTH"] [mask_value="***MASKED***"]`
- **Description:** Masks sensitive KEY=VALUE or "Header: Value" lines when the key matches any sensitive keyword.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `line` (`string`) | Input line (e.g., "API_TOKEN=secret123" or "Authorization: Bearer xyz"). |
| `[sensitive_keys_csv="PASSWORD,SECRET,TOKEN,KEY,AUTH"]` (`string`) | Comma-separated case-insensitive keywords. |
| `[mask_value="***MASKED***"]` (`string`) | Replacement value when masked. |

## Return / Exit Value

- {string} The masked line if sensitive, or the original line unchanged.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  mask_env_line "DB_PASSWORD=supersecret"
```

---

See also the full runnable example script: [`examples/16_mask_example.sh`](../../examples/16_mask_example.sh).
