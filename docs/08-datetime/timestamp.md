# `timestamp`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../08-datetime.md) › [Function Index](README.md) › **`timestamp`** › [Runnable Example](../../examples/08_datetime_example.sh) › [Tests](../../tests/08-datetime.test.sh)

- **Source:** [`functions/08-datetime.sh#L26-L32`](../../functions/08-datetime.sh#L26-L32)
- **Signature:** `timestamp`
- **Description:** Outputs the current date and time formatted according to TIMESTAMP_FORMAT.

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

- {string} The formatted timestamp.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local ts
  ts=$(timestamp)
```

---

See also the full runnable example script: [`examples/08_datetime_example.sh`](../../examples/08_datetime_example.sh).
