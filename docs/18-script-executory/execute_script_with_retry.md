# `execute_script_with_retry`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../18-script-executory.md) › [Function Index](README.md) › **`execute_script_with_retry`** › [Runnable Example](../../examples/18_script_executory_example.sh) › [Tests](../../tests/18-script-executory.test.sh)

- **Source:** [`functions/18-script-executory.sh#L302-L327`](../../functions/18-script-executory.sh#L302-L327)
- **Signature:** `execute_script_with_retry <script_path> [max_retries=3] [delay_seconds=2] [args...]`
- **Description:** Executes a script and retries up to max_retries times if it returns a non-zero exit code.

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
| `[max_retries=3]` (`number`) | Maximum number of attempts. |
| `[delay_seconds=2]` (`number`) | Delay in seconds between retries. |
| `[args...]` (`string`) | Optional arguments forwarded to the script. |

## Return / Exit Value

- {number} 0 on success, or the last non-zero exit code after exhausting retries.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  execute_script_with_retry "./login.sh" 3 1
```

### 2. Default retries (3, 2s delay) vs custom retries & forwarded args

```zsh
execute_script_with_retry "./flaky.sh"
execute_script_with_retry "./flaky.sh" 5 1 "--env" "prod"
```

---

See also the full runnable example script: [`examples/18_script_executory_example.sh`](../../examples/18_script_executory_example.sh).
