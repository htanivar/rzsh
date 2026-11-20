# `log_debug`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../01-logs.md) › [Function Index](README.md) › **`log_debug`** › [Runnable Example](../../examples/01_logs_example.sh) › [Tests](../../tests/01-logs.test.sh)

- **Source:** [`functions/01-logs.sh#L155-L157`](../../functions/01-logs.sh#L155-L157)
- **Signature:** `log_debug <message>`
- **Description:** Logs a debug message.

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
  log_debug "Connection string: $conn"
```

---

See also the full runnable example script: [`examples/01_logs_example.sh`](../../examples/01_logs_example.sh).
