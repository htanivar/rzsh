# Directory Management Module Reference

- **Source File:** [`functions/10-directory.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/10-directory.sh)
- **Description:** Folder syncs, recursive purges, watchers, and listings.

---

## Detailed Usage Examples

### Integration Setup
To use the Directory Management module, you only need to source the configuration script, which automatically imports it:

```zsh
source ./config/config.sh
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
### `dir_list`

* **Signature:** `dir_list <dir> [pattern]`
* **Description:** Lists items directly in a directory matching glob pattern (forces Zsh glob evaluation).

#### Example Code:
```zsh
local logs=$(dir_list "/var/log" "*.log")
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
