# `execute_script_in_current_shell`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../18-script-executory.md) › [Function Index](README.md) › **`execute_script_in_current_shell`** › [Runnable Example](../../examples/18_script_executory_example.sh) › [Tests](../../tests/18-script-executory.test.sh)

- **Source:** [`functions/18-script-executory.sh#L122-L145`](../../functions/18-script-executory.sh#L122-L145)
- **Signature:** `execute_script_in_current_shell <script_path> [args...]`
- **Description:** Sources a target script in the current shell so exported/global variables persist across steps.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `script_path` (`string`) | Path to the script to source. |
| `[args...]` (`string`) | Optional positional parameters passed to the sourced script. |

## Return / Exit Value

- {number} Exit code of the sourced script, or 1 if validation fails.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  execute_script_in_current_shell "./login.sh"
```

---

See also the full runnable example script: [`examples/18_script_executory_example.sh`](../../examples/18_script_executory_example.sh).
