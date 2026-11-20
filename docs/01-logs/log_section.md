# `log_section`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../01-logs.md) › [Function Index](README.md) › **`log_section`** › [Runnable Example](../../examples/01_logs_example.sh) › [Tests](../../tests/01-logs.test.sh)

- **Source:** [`functions/01-logs.sh#L206-L212`](../../functions/01-logs.sh#L206-L212)
- **Signature:** `log_section <title>`
- **Description:** Logs a section header with border lines.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `title` (`string`) | Section title. |

## Return / Exit Value

- {number} 0 on success.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  log_section "Database Migration"
```

---

See also the full runnable example script: [`examples/01_logs_example.sh`](../../examples/01_logs_example.sh).
