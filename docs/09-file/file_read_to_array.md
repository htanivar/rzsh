# `file_read_to_array`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../09-file.md) › [Function Index](README.md) › **`file_read_to_array`** › [Runnable Example](../../examples/09_file_example.sh) › [Tests](../../tests/09-file.test.sh)

- **Source:** [`functions/09-file.sh#L67-L91`](../../functions/09-file.sh#L67-L91)
- **Signature:** `file_read_to_array <file> [array_name=FILE_LINES] [skip_empty=0]`
- **Description:** Reads a file line-by-line into a Zsh array variable for iteration/looping.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `file` (`string`) | The file path to read. |
| `[array_name=FILE_LINES]` (`string`) | Name of the target array variable to populate. |
| `[skip_empty=0]` (`number`) | Set to 1 to skip blank/empty lines. |

## Return / Exit Value

- {number} 0 on success, 1 if the file does not exist or array_name is invalid.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local -a lines
  file_read_to_array "hosts.txt" "lines" 1
  for line in "${lines[@]}"; do
    echo "${line}"
  done
```

### 2. Default FILE_LINES array vs custom array & skip_empty flag

```zsh
file_read_to_array "hosts.txt"
file_read_to_array "hosts.txt" "MY_HOSTS"
file_read_to_array "hosts.txt" "MY_HOSTS" 1  # skip blank lines
```

---

See also the full runnable example script: [`examples/09_file_example.sh`](../../examples/09_file_example.sh).
