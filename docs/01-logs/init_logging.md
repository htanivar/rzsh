# `init_logging`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../01-logs.md) › [Function Index](README.md) › **`init_logging`** › [Runnable Example](../../examples/01_logs_example.sh) › [Tests](../../tests/01-logs.test.sh)

- **Source:** [`functions/01-logs.sh#L26-L53`](../../functions/01-logs.sh#L26-L53)
- **Signature:** `init_logging`
- **Description:** Initializes logging. Creates log directory and file with timestamp, and performs basic rotation (keeping last 5 logs).

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

- {number} 0 on success, 1 on failure.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  init_logging
```

---

See also the full runnable example script: [`examples/01_logs_example.sh`](../../examples/01_logs_example.sh).
