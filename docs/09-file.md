# File Utilities Module Reference

- **Source File:** [`functions/09-file.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/09-file.sh)
- **Description:** File checks, writes, reads, stat sizes, checksums, backups, and search grep.

---

## Detailed Usage Examples

### Integration Setup
To use the File Utilities module, you only need to source the configuration script, which automatically imports it:

```zsh
source ./config/config.sh
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
### `file_write / file_append`

* **Signature:** `file_write <file> <content> / file_append <file> <content>`
* **Description:** Writes or appends the content to the target file. Backslash escape sequences (e.g., \n) are interpreted.

#### Example Code:
```zsh
file_write "out.txt" "line1\nline2"
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
### `file_backup_and_restore`

* **Signature:** `file_backup_and_restore <action> <file> [backup_path]`
* **Description:** Creates a backup of a file with a timestamp suffix, or restores from it.

#### Example Code:
```zsh
file_backup_and_restore "backup" "settings.conf"
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
