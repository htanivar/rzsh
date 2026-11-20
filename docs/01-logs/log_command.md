# `log_command`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../01-logs.md) › [Function Index](README.md) › **`log_command`** › [Runnable Example](../../examples/01_logs_example.sh) › [Tests](../../tests/01-logs.test.sh)

- **Source:** [`functions/01-logs.sh#L181-L196`](../../functions/01-logs.sh#L181-L196)
- **Signature:** `log_command <command>`
- **Description:** Executes a command, logging both its execution start/end and redirecting its output to the log file.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `command` (`string`) | Command to run. |

## Return / Exit Value

- {number} Exit code of the executed command.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  log_command "npm install"
```

---

See also the full runnable example script: [`examples/01_logs_example.sh`](../../examples/01_logs_example.sh).
