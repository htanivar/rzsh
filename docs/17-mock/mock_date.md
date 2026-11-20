# `mock_date`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../17-mock.md) › [Function Index](README.md) › **`mock_date`** › [Runnable Example](../../examples/17_mock_example.sh) › [Tests](../../tests/17-mock.test.sh)

- **Source:** [`functions/17-mock.sh#L264-L267`](../../functions/17-mock.sh#L264-L267)
- **Signature:** `mock_date [format="%Y-%m-%d"]`
- **Description:** Prints a formatted timestamp/date string (defaults to YYYY-MM-DD).

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `[format="%Y-%m-%d"]` (`string`) | strftime format string. |

## Return / Exit Value

- {string} Formatted date string.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  ts=$(mock_date "%Y-%m-%dT%H:%M:%SZ")
```

---

See also the full runnable example script: [`examples/17_mock_example.sh`](../../examples/17_mock_example.sh).
