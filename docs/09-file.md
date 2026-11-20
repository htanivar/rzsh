# File Utilities Module Reference

**Navigation:** [README](../README.md) › [GLOSSARY](../GLOSSARY.md) › **09-file.md** › [Example](../examples/09_file_example.sh) › [Tests](../tests/09-file.test.sh)

- **Source File:** [`functions/09-file.sh`](../functions/09-file.sh)
- **Description:** File checks, writes, reads, stat sizes, checksums, backups, and search grep.

---

## Detailed Usage Examples

### Integration Setup
To use the File Utilities module, source the configuration script via `RZSH_DIR`, which automatically imports it:

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

---

## Function Signatures & Descriptions

### `file_exists`

* **Signature:** `file_exists <file_path>`
* **Description:** Returns 0 if the path points to a file, 1 otherwise.

#### Example Code:
```zsh
file_exists "/etc/hosts"
```

---
### `file_read / file_write / file_append`

* **Signature:** `file_read <file> / file_write <file> <content> / file_append <file> <content>`
* **Description:** Reads, writes, or appends content to the target file.

#### Example Code:
```zsh
file_write "out.txt" "line1\nline2"
local content=$(file_read "out.txt")
```

---
### `file_read_to_array`

* **Signature:** `file_read_to_array <file_path> [array_name=FILE_LINES] [skip_empty=0]`
* **Description:** Reads a file line-by-line into a Zsh array variable (defaulting to `FILE_LINES`) so it can be iterated over in a loop. Pass `1` as the third argument to skip blank/whitespace-only lines.

#### Example Code:
```zsh
local -a lines
file_read_to_array "hosts.txt" "lines" 1

for line in "${lines[@]}"; do
  echo "Processing: ${line}"
done
```

---
### `file_copy / file_move / file_delete`

* **Signature:** `file_copy <src> <dest> / file_move <src> <dest> / file_delete <file>`
* **Description:** Performs file operations (copy, move, delete) safely, with prompt fallback.

#### Example Code:
```zsh
file_copy "a.txt" "b.txt"
```

---
### `file_get_size`

* **Signature:** `file_get_size <file>`
* **Description:** Outputs the size of a file in bytes using the Zsh stat module.

#### Example Code:
```zsh
local size=$(file_get_size "data.db")
```

---
### `file_get_permissions / file_set_permissions / file_get_owner / file_get_group`

* **Signature:** `file_get_permissions <file> / file_set_permissions <file> <mode> / file_get_owner <file> / file_get_group <file>`
* **Description:** Queries or modifies file octal permissions (`chmod`) and inspects file owner and group metadata.

#### Example Code:
```zsh
file_set_permissions "script.sh" "755"
local perms=$(file_get_permissions "script.sh")
local owner=$(file_get_owner "script.sh")
local group=$(file_get_group "script.sh")
```

---
### `file_backup / file_restore / file_backup_and_restore`

* **Signature:** `file_backup <file> / file_restore <backup_file> [target] / file_backup_and_restore <action> <file>`
* **Description:** Creates a timestamped `.bak` backup of a file, or restores a file from its backup.

#### Example Code:
```zsh
local bak=$(file_backup "settings.conf")
file_restore "${bak}" "settings.conf"
```

---
### `file_hash`

* **Signature:** `file_hash <file> <algorithm>`
* **Description:** Computes the cryptographic hash (sha256, sha1, md5) of a file.

#### Example Code:
```zsh
local sha=$(file_hash "dist.tar.gz" "sha256")
```

---
### `file_head / file_tail / file_grep`

* **Signature:** `file_head <file> <lines> / file_tail <file> <lines> / file_grep <file> <pattern>`
* **Description:** Reads head/tail lines or searches matching lines in a file.

#### Example Code:
```zsh
local top5=$(file_head "data.log" 5)
```

---
### `file_equals`

* **Signature:** `file_equals <file1> <file2>`
* **Description:** Checks whether two files have identical byte-for-byte contents. Returns `0` if identical, `1` if different, and `2` if either file is missing.

#### Example Code:
```zsh
if file_equals "config.v1.json" "config.v2.json"; then
  echo "Files are identical"
else
  echo "Files differ"
fi
```

---
### `file_compare`

* **Signature:** `file_compare [options] <file1> <file2>`
* **Description:** Compares two files (size in bytes, line count, SHA-256 checksum, and unified diff) and prints/writes a structured Markdown report. Returns `0` if identical, `1` if different, `2` on invalid arguments or missing file.

#### Options:
* `-h, --help`: Show help message.
* `-o, --output <file>`: Write the Markdown comparison report to `<file>`.
* `-s, --silent`: Suppress stdout output (still writes to `-o` if specified).
* `-u, --unified <lines>`: Number of unified diff context lines (default: `3`).

#### Example Code:
```zsh
# Print comparison report to stdout
file_compare "app_v1.conf" "app_v2.conf"

# Save report silently to a Markdown file with 5 lines of diff context
file_compare -s -u 5 -o "./file_diff_report.md" "app_v1.conf" "app_v2.conf"
```

---

---

## Per-Function Copy-Paste Reference

Browse dedicated per-function pages with all flags and copy-paste variations in [`docs/09-file/`](09-file/README.md), or run [`examples/09_file_example.sh`](../examples/09_file_example.sh).

| Function | Per-Function Docs & Flags | Runnable Example |
| :--- | :--- | :--- |
| `file_exists` | [Docs & Examples](09-file/file_exists.md) | [`09_file_example.sh`](../examples/09_file_example.sh) |
| `file_read` | [Docs & Examples](09-file/file_read.md) | [`09_file_example.sh`](../examples/09_file_example.sh) |
| `file_read_to_array` | [Docs & Examples](09-file/file_read_to_array.md) | [`09_file_example.sh`](../examples/09_file_example.sh) |
| `file_write` | [Docs & Examples](09-file/file_write.md) | [`09_file_example.sh`](../examples/09_file_example.sh) |
| `file_append` | [Docs & Examples](09-file/file_append.md) | [`09_file_example.sh`](../examples/09_file_example.sh) |
| `file_copy` | [Docs & Examples](09-file/file_copy.md) | [`09_file_example.sh`](../examples/09_file_example.sh) |
| `file_move` | [Docs & Examples](09-file/file_move.md) | [`09_file_example.sh`](../examples/09_file_example.sh) |
| `file_delete` | [Docs & Examples](09-file/file_delete.md) | [`09_file_example.sh`](../examples/09_file_example.sh) |
| `file_get_size` | [Docs & Examples](09-file/file_get_size.md) | [`09_file_example.sh`](../examples/09_file_example.sh) |
| `file_get_permissions` | [Docs & Examples](09-file/file_get_permissions.md) | [`09_file_example.sh`](../examples/09_file_example.sh) |
| `file_set_permissions` | [Docs & Examples](09-file/file_set_permissions.md) | [`09_file_example.sh`](../examples/09_file_example.sh) |
| `file_get_owner` | [Docs & Examples](09-file/file_get_owner.md) | [`09_file_example.sh`](../examples/09_file_example.sh) |
| `file_get_group` | [Docs & Examples](09-file/file_get_group.md) | [`09_file_example.sh`](../examples/09_file_example.sh) |
| `file_backup` | [Docs & Examples](09-file/file_backup.md) | [`09_file_example.sh`](../examples/09_file_example.sh) |
| `file_restore` | [Docs & Examples](09-file/file_restore.md) | [`09_file_example.sh`](../examples/09_file_example.sh) |
| `file_backup_and_restore` | [Docs & Examples](09-file/file_backup_and_restore.md) | [`09_file_example.sh`](../examples/09_file_example.sh) |
| `file_hash` | [Docs & Examples](09-file/file_hash.md) | [`09_file_example.sh`](../examples/09_file_example.sh) |
| `file_tail` | [Docs & Examples](09-file/file_tail.md) | [`09_file_example.sh`](../examples/09_file_example.sh) |
| `file_head` | [Docs & Examples](09-file/file_head.md) | [`09_file_example.sh`](../examples/09_file_example.sh) |
| `file_grep` | [Docs & Examples](09-file/file_grep.md) | [`09_file_example.sh`](../examples/09_file_example.sh) |
| `file_equals` | [Docs & Examples](09-file/file_equals.md) | [`09_file_example.sh`](../examples/09_file_example.sh) |
| `file_compare` | [Docs & Examples](09-file/file_compare.md) | [`09_file_example.sh`](../examples/09_file_example.sh) |