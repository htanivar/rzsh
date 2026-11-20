# `error_exit`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../02-errors.md) › [Function Index](README.md) › **`error_exit`** › [Runnable Example](../../examples/02_errors_example.sh) › [Tests](../../tests/02-errors.test.sh)

- **Source:** [`functions/02-errors.sh#L26-L51`](../../functions/02-errors.sh#L26-L51)
- **Signature:** `error_exit <message> [exit_code=1]`
- **Description:** Logs a fatal error message, prints the current call stack trace, cleans up registered temporary files, and exits the script.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `message` (`string`) | The error message. |
| `[exit_code=1]` (`number`) | The exit status code. |

## Return / Exit Value

- {void}

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  error_exit "Database connection failed" 2
```

---

See also the full runnable example script: [`examples/02_errors_example.sh`](../../examples/02_errors_example.sh).
