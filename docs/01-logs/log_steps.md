# `log_steps`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../01-logs.md) › [Function Index](README.md) › **`log_steps`** › [Runnable Example](../../examples/01_logs_example.sh) › [Tests](../../tests/01-logs.test.sh)

- **Source:** [`functions/01-logs.sh#L167-L171`](../../functions/01-logs.sh#L167-L171)
- **Signature:** `log_steps <step_name>`
- **Description:** Logs progress tracking steps with an incrementing counter.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `step_name` (`string`) | Name of the step. |

## Return / Exit Value

- {number} 0 on success.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  log_steps "Compile sources"
```

---

See also the full runnable example script: [`examples/01_logs_example.sh`](../../examples/01_logs_example.sh).
