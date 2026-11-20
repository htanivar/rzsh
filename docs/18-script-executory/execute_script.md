# `execute_script`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../18-script-executory.md) › [Function Index](README.md) › **`execute_script`** › [Runnable Example](../../examples/18_script_executory_example.sh) › [Tests](../../tests/18-script-executory.test.sh)

- **Source:** [`functions/18-script-executory.sh#L86-L111`](../../functions/18-script-executory.sh#L86-L111)
- **Signature:** `execute_script <script_path> [args...]`
- **Description:** Executes a target script in a Zsh subprocess with optional arguments and logs timing/status.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `script_path` (`string`) | Path to the script to execute. |
| `[args...]` (`string`) | Optional arguments forwarded to the script. |

## Return / Exit Value

- {number} Exit code of the executed script, or 1 if validation fails.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  execute_script "./login.sh" "--env" "prod"
```

---

See also the full runnable example script: [`examples/18_script_executory_example.sh`](../../examples/18_script_executory_example.sh).
