# `format_duration`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../08-datetime.md) › [Function Index](README.md) › **`format_duration`** › [Runnable Example](../../examples/08_datetime_example.sh) › [Tests](../../tests/08-datetime.test.sh)

- **Source:** [`functions/08-datetime.sh#L266-L284`](../../functions/08-datetime.sh#L266-L284)
- **Signature:** `format_duration <seconds>`
- **Description:** Formats a number of seconds into a human-readable duration (e.g., 2h 15m 5s).

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `seconds` (`number`) | Number of seconds. |

## Return / Exit Value

- {string} Human-readable duration.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  format_duration 8130
```

---

See also the full runnable example script: [`examples/08_datetime_example.sh`](../../examples/08_datetime_example.sh).
