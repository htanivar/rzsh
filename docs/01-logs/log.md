# `log`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../01-logs.md) › [Function Index](README.md) › **`log`** › [Runnable Example](../../examples/01_logs_example.sh) › [Tests](../../tests/01-logs.test.sh)

- **Source:** [`functions/01-logs.sh#L64-L109`](../../functions/01-logs.sh#L64-L109)
- **Signature:** `log <level> <message>`
- **Description:** Core log function formatting and writing output to console (stderr) and file.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `level` (`string`) | Log level (DEBUG, INFO, WARN, ERROR). |
| `message` (`string`) | Message to log. |

## Return / Exit Value

- {number} 0 on success.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  log "INFO" "Starting build process"
```

### 2. Log at each severity level

```zsh
log "INFO" "Deployment started"
log "WARN" "Cache miss, falling back to login"
log "ERROR" "Failed to reach upstream API"
log "DEBUG" "Payload size: 512 bytes"
```

---

See also the full runnable example script: [`examples/01_logs_example.sh`](../../examples/01_logs_example.sh).
