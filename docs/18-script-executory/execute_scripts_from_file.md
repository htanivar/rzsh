# `execute_scripts_from_file`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../18-script-executory.md) › [Function Index](README.md) › **`execute_scripts_from_file`** › [Runnable Example](../../examples/18_script_executory_example.sh) › [Tests](../../tests/18-script-executory.test.sh)

- **Source:** [`functions/18-script-executory.sh#L262-L289`](../../functions/18-script-executory.sh#L262-L289)
- **Signature:** `execute_scripts_from_file <manifest_file> [flags...]`
- **Description:** Reads an ordered list of script paths from a manifest file (ignoring blank lines and # comments) and executes them sequentially.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `manifest_file` (`string`) | Path to the manifest file containing one script path per line. |
| `[flags...]` (`string`) | Optional flags forwarded to execute_scripts_sequence (--continue-on-error, --source, --dry-run). |

## Return / Exit Value

- {number} 0 if all scripts succeed, non-zero otherwise.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  execute_scripts_from_file "./pipeline.txt"
```

### 2. Run manifest with forwarded sequence flags

```zsh
execute_scripts_from_file "./pipeline.txt"
execute_scripts_from_file "./pipeline.txt" --dry-run
execute_scripts_from_file "./pipeline.txt" --source --continue-on-error
```

---

See also the full runnable example script: [`examples/18_script_executory_example.sh`](../../examples/18_script_executory_example.sh).
