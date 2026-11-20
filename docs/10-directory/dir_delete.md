# `dir_delete`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../10-directory.md) › [Function Index](README.md) › **`dir_delete`** › [Runnable Example](../../examples/10_directory_example.sh) › [Tests](../../tests/10-directory.test.sh)

- **Source:** [`functions/10-directory.sh#L58-L79`](../../functions/10-directory.sh#L58-L79)
- **Signature:** `dir_delete <dir> [option]`
- **Description:** Deletes a directory recursively. Requires confirmation unless --force or -f is passed.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `dir` (`string`) | Directory path. |
| `[option]` (`string`) | Pass '--force' or '-f' to skip interactive confirmation. |

## Return / Exit Value

- {number} 0 on success, 1 on failure or if canceled.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  dir_delete "/tmp/my_app/temp" "--force"
```

### 2. Interactive confirmation (default)

```zsh
dir_delete "/tmp/build_artifacts"
```

### 3. Skip confirmation with --force or -f

```zsh
dir_delete "/tmp/build_artifacts" "--force"
dir_delete "/tmp/build_artifacts" "-f"
```

---

See also the full runnable example script: [`examples/10_directory_example.sh`](../../examples/10_directory_example.sh).
