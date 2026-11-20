# `date_now`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../08-datetime.md) › [Function Index](README.md) › **`date_now`** › [Runnable Example](../../examples/08_datetime_example.sh) › [Tests](../../tests/08-datetime.test.sh)

- **Source:** [`functions/08-datetime.sh#L43-L49`](../../functions/08-datetime.sh#L43-L49)
- **Signature:** `date_now`
- **Description:** Outputs the current date formatted according to DATE_FORMAT.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| — | None |

## Return / Exit Value

- {string} The formatted date.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local dt
  dt=$(date_now)
```

---

See also the full runnable example script: [`examples/08_datetime_example.sh`](../../examples/08_datetime_example.sh).
