# `timezone_convert`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../08-datetime.md) › [Function Index](README.md) › **`timezone_convert`** › [Runnable Example](../../examples/08_datetime_example.sh) › [Tests](../../tests/08-datetime.test.sh)

- **Source:** [`functions/08-datetime.sh#L208-L213`](../../functions/08-datetime.sh#L208-L213)
- **Signature:** `timezone_convert <date> <from_tz> <to_tz>`
- **Description:** Converts a date string from one timezone to another.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `date` (`string`) | The date string. |
| `from_tz` (`string`) | Source timezone (e.g. UTC, America/New_York). |
| `to_tz` (`string`) | Destination timezone. |

## Return / Exit Value

- {string} Converted date in YYYY-MM-DD HH:MM:SS format.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  timezone_convert "2026-07-08 12:00:00" "UTC" "America/New_York"
```

---

See also the full runnable example script: [`examples/08_datetime_example.sh`](../../examples/08_datetime_example.sh).
