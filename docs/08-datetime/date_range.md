# `date_range`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../08-datetime.md) › [Function Index](README.md) › **`date_range`** › [Runnable Example](../../examples/08_datetime_example.sh) › [Tests](../../tests/08-datetime.test.sh)

- **Source:** [`functions/08-datetime.sh#L239-L256`](../../functions/08-datetime.sh#L239-L256)
- **Signature:** `date_range <start> <end> [interval="1 day"]`
- **Description:** Prints a range of dates from start to end with the specified interval.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `start` (`string`) | Start date. |
| `end` (`string`) | End date. |
| `[interval="1` (`string`) | day"] - Interval duration string. |

## Return / Exit Value

- {string} Newline-separated list of dates.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  date_range "2026-07-01" "2026-07-05" "1 day"
```

---

See also the full runnable example script: [`examples/08_datetime_example.sh`](../../examples/08_datetime_example.sh).
