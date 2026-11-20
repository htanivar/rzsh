# `date_add`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../08-datetime.md) › [Function Index](README.md) › **`date_add`** › [Runnable Example](../../examples/08_datetime_example.sh) › [Tests](../../tests/08-datetime.test.sh)

- **Source:** [`functions/08-datetime.sh#L129-L138`](../../functions/08-datetime.sh#L129-L138)
- **Signature:** `date_add <date> <duration>`
- **Description:** Adds a duration (e.g., "1 day", "2 hours") to a starting date-time.

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
| `duration` (`string`) | Duration string to add. |

## Return / Exit Value

- {string} Resulting date string in YYYY-MM-DD HH:MM:SS format.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local future
  future=$(date_add "2026-07-08 12:00:00" "2 days")
```

---

See also the full runnable example script: [`examples/08_datetime_example.sh`](../../examples/08_datetime_example.sh).
