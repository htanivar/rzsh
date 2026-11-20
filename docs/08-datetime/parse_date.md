# `parse_date`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../08-datetime.md) › [Function Index](README.md) › **`parse_date`** › [Runnable Example](../../examples/08_datetime_example.sh) › [Tests](../../tests/08-datetime.test.sh)

- **Source:** [`functions/08-datetime.sh#L60-L84`](../../functions/08-datetime.sh#L60-L84)
- **Signature:** `parse_date <date_string>`
- **Description:** Parses a date string and prints its representation in epoch seconds.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `date_string` (`string`) | The date string to parse. |

## Return / Exit Value

- {number} Epoch seconds.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local epoch
  epoch=$(parse_date "2026-07-08 12:00:00")
```

---

See also the full runnable example script: [`examples/08_datetime_example.sh`](../../examples/08_datetime_example.sh).
