# `date_format`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../08-datetime.md) › [Function Index](README.md) › **`date_format`** › [Runnable Example](../../examples/08_datetime_example.sh) › [Tests](../../tests/08-datetime.test.sh)

- **Source:** [`functions/08-datetime.sh#L190-L196`](../../functions/08-datetime.sh#L190-L196)
- **Signature:** `date_format <date> <format>`
- **Description:** Formats a date string using the specified format.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `date` (`string`) | The date to format. |
| `format` (`string`) | Strftime format string. |

## Return / Exit Value

- {string} Formatted date.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  date_format "2026-07-08" "%A, %B %d, %Y"
```

---

See also the full runnable example script: [`examples/08_datetime_example.sh`](../../examples/08_datetime_example.sh).
