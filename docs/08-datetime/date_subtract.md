# `date_subtract`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../08-datetime.md) › [Function Index](README.md) › **`date_subtract`** › [Runnable Example](../../examples/08_datetime_example.sh) › [Tests](../../tests/08-datetime.test.sh)

- **Source:** [`functions/08-datetime.sh#L150-L159`](../../functions/08-datetime.sh#L150-L159)
- **Signature:** `date_subtract <date> <duration>`
- **Description:** Subtracts a duration (e.g., "1 day", "2 hours") from a starting date-time.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `date` (`string`) | Starting date string. |
| `duration` (`string`) | Duration string to subtract. |

## Return / Exit Value

- {string} Resulting date string in YYYY-MM-DD HH:MM:SS format.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local past
  past=$(date_subtract "2026-07-08 12:00:00" "1 hour")
```

---

See also the full runnable example script: [`examples/08_datetime_example.sh`](../../examples/08_datetime_example.sh).
