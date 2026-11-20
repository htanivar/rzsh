# `file_compare`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../09-file.md) › [Function Index](README.md) › **`file_compare`** › [Runnable Example](../../examples/09_file_example.sh) › [Tests](../../tests/09-file.test.sh)

- **Source:** [`functions/09-file.sh#L455-L581`](../../functions/09-file.sh#L455-L581)
- **Signature:** `file_compare [options] <file1> <file2>`
- **Description:** Compares two files (size, SHA-256 hash, line count, unified diff) and prints/writes a Markdown report.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `[options]` (`string`) | -h/--help, -o/--output <file>, -s/--silent, -u/--unified <lines>. |
| `file1` (`string`) | First (base) file path. |
| `file2` (`string`) | Second (target) file path. |

## Flags & Options

```text
-h, --help             Show this help message.
  -o, --output <file>    Write the Markdown comparison report to <file>.
  -s, --silent           Suppress stdout output (still writes to -o if specified).
  -u, --unified <lines>  Number of unified diff context lines (default: 3).
```

## Return / Exit Value

- {number} 0 if identical, 1 if different, 2 on error/missing file.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  file_compare -o report.md config_v1.env config_v2.env
```

### 2. Print report to stdout (default 3 context lines)

```zsh
file_compare "config_v1.env" "config_v2.env"
```

### 3. Custom diff context (-u / --unified)

```zsh
file_compare -u 5 "config_v1.env" "config_v2.env"
file_compare --unified 0 "config_v1.env" "config_v2.env"
```

### 4. Write Markdown report silently (-s -o / --silent --output)

```zsh
file_compare -s -o "./logs/file_diff.md" "config_v1.env" "config_v2.env"
file_compare --silent --output "./logs/file_diff.md" --unified 5 "config_v1.env" "config_v2.env"
```

### 5. Show help (-h / --help)

```zsh
file_compare --help
```

---

See also the full runnable example script: [`examples/09_file_example.sh`](../../examples/09_file_example.sh).
