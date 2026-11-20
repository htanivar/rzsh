# `mock_command`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../17-mock.md) › [Function Index](README.md) › **`mock_command`** › [Runnable Example](../../examples/17_mock_example.sh) › [Tests](../../tests/17-mock.test.sh)

- **Source:** [`functions/17-mock.sh#L450-L475`](../../functions/17-mock.sh#L450-L475)
- **Signature:** `mock_command <cmd_name> [stdout_output=""] [exit_code=0]`
- **Description:** Mocks a shell command or Zsh function with a static stdout response and exit code, tracking call counts and arguments.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `cmd_name` (`string`) | Name of the command or function to mock. |
| `[stdout_output=""]` (`string`) | Output to print to stdout when invoked. |
| `[exit_code=0]` (`number`) | Exit status code to return when invoked. |

## Return / Exit Value

- {number} 0 on success, 1 if cmd_name is invalid.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  mock_command "git" "main" 0
```

---

See also the full runnable example script: [`examples/17_mock_example.sh`](../../examples/17_mock_example.sh).
