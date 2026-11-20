# `str_starts_with`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../11-string.md) › [Function Index](README.md) › **`str_starts_with`** › [Runnable Example](../../examples/11_string_example.sh) › [Tests](../../tests/11-string.test.sh)

- **Source:** [`functions/11-string.sh#L45-L52`](../../functions/11-string.sh#L45-L52)
- **Signature:** `str_starts_with <str> <prefix>`
- **Description:** Checks if a string starts with a specified prefix.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `str` (`string`) | The main string. |
| `prefix` (`string`) | The prefix. |

## Return / Exit Value

- {number} 0 if matches, 1 otherwise.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  if str_starts_with "http://google.com" "http://"; then
    echo "Matches"
  fi
```

---

See also the full runnable example script: [`examples/11_string_example.sh`](../../examples/11_string_example.sh).
