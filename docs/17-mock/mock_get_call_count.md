# `mock_get_call_count`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../17-mock.md) › [Function Index](README.md) › **`mock_get_call_count`** › [Runnable Example](../../examples/17_mock_example.sh) › [Tests](../../tests/17-mock.test.sh)

- **Source:** [`functions/17-mock.sh#L500-L508`](../../functions/17-mock.sh#L500-L508)
- **Signature:** `mock_get_call_count <cmd_name>`
- **Description:** Prints the number of times a mocked command/function has been invoked.

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

- {number} Call count integer printed to stdout.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  count=$(mock_get_call_count "curl")
```

---

See also the full runnable example script: [`examples/17_mock_example.sh`](../../examples/17_mock_example.sh).
