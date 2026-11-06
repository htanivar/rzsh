# Directory Management Module Reference

- **Source File:** [`functions/10-directory.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/10-directory.sh)
- **Description:** Folder syncs, recursive purges, watchers, and listings.

---

## Detailed Usage Examples

### Integration Setup
To use the Directory Management module, source the configuration script via `RZSH_DIR`, which automatically imports it:

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

---

## Function Signatures & Descriptions

### `dir_exists / dir_create`

* **Signature:** `dir_exists <dir> / dir_create <dir>`
* **Description:** Checks if directory exists, or creates it recursively.

#### Example Code:
```zsh
dir_create "/tmp/workspace/src"
```

---
### `dir_is_empty / dir_clean`

* **Signature:** `dir_is_empty <dir> / dir_clean <dir>`
* **Description:** Checks if directory has no files, or deletes all contents.

#### Example Code:
```zsh
dir_clean "/tmp/workspace"
```

---
### `dir_copy / dir_move / dir_delete`

* **Signature:** `dir_copy <src> <dest> / dir_move <src> <dest> / dir_delete <dir> [--force]`
* **Description:** Copies, moves, or deletes directories recursively. --force skips interactive confirmations.

#### Example Code:
```zsh
dir_delete "/tmp/workspace" "--force"
```

---
### `dir_list / dir_size / dir_tree`

* **Signature:** `dir_list <dir> [pattern] / dir_size <dir> / dir_tree <dir> [max_depth]`
* **Description:** Lists items directly in a directory matching a glob pattern, outputs human-readable disk usage (`dir_size`), or renders an indented visual directory tree (`dir_tree`).

#### Example Code:
```zsh
local logs=$(dir_list "/var/log" "*.log")
local usage=$(dir_size "/var/log")
dir_tree "./src" 2
```

---
### `dir_sync`

* **Signature:** `dir_sync <src> <dest>`
* **Description:** Synchronizes files from source to destination directory (non-destructively).

#### Example Code:
```zsh
dir_sync "/etc/nginx/sites-available" "/etc/nginx/sites-enabled"
```

---
### `dir_watch`

* **Signature:** `dir_watch <dir> <callback_function> [interval_seconds]`
* **Description:** Monitors a folder's contents and triggers a callback when updates occur.

#### Example Code:
```zsh
dir_watch "./src" "recompile_app" 2
```

---
