# `date_diff`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../08-datetime.md) › [Function Index](README.md) › **`date_diff`** › [Runnable Example](../../examples/08_datetime_example.sh) › [Tests](../../tests/08-datetime.test.sh)

- **Source:** [`functions/08-datetime.sh#L171-L179`](../../functions/08-datetime.sh#L171-L179)
- **Signature:** `date_diff <date1> <date2>`
- **Description:** Calculates the difference (in seconds) between two dates.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `date1` (`string`) | First date. |
| `date2` (`string`) | Second date. |

## Return / Exit Value

- {number} Difference in seconds.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local diff
  diff=$(date_diff "2026-07-08 12:00:00" "2026-07-08 12:01:30")
```

---

See also the full runnable example script: [`examples/08_datetime_example.sh`](../../examples/08_datetime_example.sh).
