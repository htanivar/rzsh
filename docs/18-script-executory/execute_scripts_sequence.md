# `execute_scripts_sequence`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../18-script-executory.md) › [Function Index](README.md) › **`execute_scripts_sequence`** › [Runnable Example](../../examples/18_script_executory_example.sh) › [Tests](../../tests/18-script-executory.test.sh)

- **Source:** [`functions/18-script-executory.sh#L158-L251`](../../functions/18-script-executory.sh#L158-L251)
- **Signature:** `execute_scripts_sequence [--continue-on-error] [--source] [--dry-run] <scripts...>`
- **Description:** Executes multiple scripts sequentially in the specified order.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `[--continue-on-error]` (`string`) | Continue running remaining scripts even if one fails. |
| `[--source]` (`string`) | Source scripts in the current shell instead of running in subshells. |
| `[--dry-run]` (`string`) | Validate and print the execution plan without running the scripts. |
| `scripts...` (`string`) | Ordered list of script paths to execute. |

## Return / Exit Value

- {number} 0 if all scripts succeed, or non-zero exit code on failure.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  execute_scripts_sequence "./login.sh" "./verify.sh" "./update.sh"
```

### 2. Fail-fast sequential execution (default)

```zsh
execute_scripts_sequence "./login.sh" "./verify.sh" "./update.sh"
```

### 3. Dry-run validation without executing (--dry-run)

```zsh
execute_scripts_sequence --dry-run "./login.sh" "./verify.sh" "./update.sh"
```

### 4. Share shell variables across scripts (--source)

```zsh
execute_scripts_sequence --source "./login.sh" "./verify.sh" "./update.sh"
```

### 5. Continue on error + source + dry-run combinations

```zsh
execute_scripts_sequence --continue-on-error "./s1.sh" "./s2.sh" "./s3.sh"
execute_scripts_sequence --continue-on-error --source "./login.sh" "./verify.sh"
```

---

See also the full runnable example script: [`examples/18_script_executory_example.sh`](../../examples/18_script_executory_example.sh).
