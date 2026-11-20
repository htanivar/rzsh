# `dir_compare`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../10-directory.md) › [Function Index](README.md) › **`dir_compare`** › [Runnable Example](../../examples/10_directory_example.sh) › [Tests](../../tests/10-directory.test.sh)

- **Source:** [`functions/10-directory.sh#L337-L551`](../../functions/10-directory.sh#L337-L551)
- **Signature:** `dir_compare [options] <dir1> <dir2>`
- **Description:** Recursively compares two directories and generates a Markdown report of added, removed, modified, and identical files.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `[options]` (`string`) | -h/--help, -o/--output <file>, -s/--silent, --diff, --ignore <csv>. |
| `dir1` (`string`) | First (base) directory path. |
| `dir2` (`string`) | Second (target) directory path. |

## Flags & Options

```text
-h, --help            Show this help message.
  -o, --output <file>   Write the Markdown comparison report to <file>.
  -s, --silent          Suppress stdout output (still writes to -o if specified).
      --diff            Include unified diffs for modified files.
      --ignore <csv>    Comma-separated folder/file names to ignore (default: $GIT_IGNORE_FOLDERS or ".git,.idea,vendor").
```

## Return / Exit Value

- {number} 0 if directories are identical, 1 if differences exist, 2 on invalid arguments or missing directory.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  dir_compare --diff -o dir_report.md ./build_v1 ./build_v2
```

### 2. Compare two directories to stdout

```zsh
dir_compare "./build_v1" "./build_v2"
```

### 3. Include unified diffs for modified files (--diff)

```zsh
dir_compare --diff "./build_v1" "./build_v2"
```

### 4. Custom ignore patterns (--ignore) and silent file output (-s -o)

```zsh
dir_compare --ignore ".git,node_modules,dist" --diff "./src_a" "./src_b"
dir_compare -s -o "./logs/dir_report.md" --diff "./build_v1" "./build_v2"
```

### 5. Show help (-h / --help)

```zsh
dir_compare --help
```

---

See also the full runnable example script: [`examples/10_directory_example.sh`](../../examples/10_directory_example.sh).
