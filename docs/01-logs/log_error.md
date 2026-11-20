# `log_error`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../01-logs.md) › [Function Index](README.md) › **`log_error`** › [Runnable Example](../../examples/01_logs_example.sh) › [Tests](../../tests/01-logs.test.sh)

- **Source:** [`functions/01-logs.sh#L131-L133`](../../functions/01-logs.sh#L131-L133)
- **Signature:** `log_error <message>`
- **Description:** Logs an error message.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `message` (`string`) | Message to log. |

## Return / Exit Value

- {number} 0 on success.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  log_error "Failed to connect to database"
```

---

See also the full runnable example script: [`examples/01_logs_example.sh`](../../examples/01_logs_example.sh).
