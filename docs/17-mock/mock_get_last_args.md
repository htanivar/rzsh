# `mock_get_last_args`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../17-mock.md) › [Function Index](README.md) › **`mock_get_last_args`** › [Runnable Example](../../examples/17_mock_example.sh) › [Tests](../../tests/17-mock.test.sh)

- **Source:** [`functions/17-mock.sh#L518-L526`](../../functions/17-mock.sh#L518-L526)
- **Signature:** `mock_get_last_args <cmd_name>`
- **Description:** Prints the argument string passed during the most recent call to a mocked command.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `cmd_name` (`string`) | Name of the mocked command. |

## Return / Exit Value

- {string} Arguments from the last invocation.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  args=$(mock_get_last_args "git")
```

---

See also the full runnable example script: [`examples/17_mock_example.sh`](../../examples/17_mock_example.sh).
