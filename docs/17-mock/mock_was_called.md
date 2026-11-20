# `mock_was_called`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../17-mock.md) › [Function Index](README.md) › **`mock_was_called`** › [Runnable Example](../../examples/17_mock_example.sh) › [Tests](../../tests/17-mock.test.sh)

- **Source:** [`functions/17-mock.sh#L537-L550`](../../functions/17-mock.sh#L537-L550)
- **Signature:** `mock_was_called <cmd_name> [expected_count]`
- **Description:** Checks whether a mocked command was called (at least once, or an exact expected count).

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
| `[expected_count]` (`number`) | Optional exact call count to assert. |

## Return / Exit Value

- {number} 0 if the expectation is met, 1 otherwise.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  mock_was_called "curl" 1
```

---

See also the full runnable example script: [`examples/17_mock_example.sh`](../../examples/17_mock_example.sh).
