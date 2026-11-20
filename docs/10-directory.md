# Directory Management Module Reference

**Navigation:** [README](../README.md) › [GLOSSARY](../GLOSSARY.md) › **10-directory.md** › [Example](../examples/10_directory_example.sh) › [Tests](../tests/10-directory.test.sh)

- **Source File:** [`functions/10-directory.sh`](../functions/10-directory.sh)
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
### `dir_compare`

* **Signature:** `dir_compare [options] <dir1> <dir2>`
* **Description:** Recursively compares two directories and generates a Markdown report detailing files only in `<dir1>`, files only in `<dir2>`, modified files, and identical file counts. Returns `0` if identical, `1` if differences exist, `2` on invalid arguments or missing directory.

#### Options:
* `-h, --help`: Show help message.
* `-o, --output <file>`: Write the Markdown comparison report to `<file>`.
* `-s, --silent`: Suppress stdout output (still writes to `-o` if specified).
* `--diff`: Include unified diffs for modified files.
* `--ignore <csv>`: Comma-separated folder/file names to ignore (defaults to `GIT_IGNORE_FOLDERS` or `.git,.idea,vendor`).

#### Example Code:
```zsh
# Compare two directories and include diffs for modified files
dir_compare --diff "./release_v1" "./release_v2"

# Save comparison report silently while ignoring build/dist folders
dir_compare -s --ignore ".git,node_modules,dist" -o "./dir_report.md" "./src_a" "./src_b"
```

---

---

## Per-Function Copy-Paste Reference

Browse dedicated per-function pages with all flags and copy-paste variations in [`docs/10-directory/`](10-directory/README.md), or run [`examples/10_directory_example.sh`](../examples/10_directory_example.sh).

| Function | Per-Function Docs & Flags | Runnable Example |
| :--- | :--- | :--- |
| `dir_exists` | [Docs & Examples](10-directory/dir_exists.md) | [`10_directory_example.sh`](../examples/10_directory_example.sh) |
| `dir_create` | [Docs & Examples](10-directory/dir_create.md) | [`10_directory_example.sh`](../examples/10_directory_example.sh) |
| `dir_delete` | [Docs & Examples](10-directory/dir_delete.md) | [`10_directory_example.sh`](../examples/10_directory_example.sh) |
| `dir_copy` | [Docs & Examples](10-directory/dir_copy.md) | [`10_directory_example.sh`](../examples/10_directory_example.sh) |
| `dir_move` | [Docs & Examples](10-directory/dir_move.md) | [`10_directory_example.sh`](../examples/10_directory_example.sh) |
| `dir_list` | [Docs & Examples](10-directory/dir_list.md) | [`10_directory_example.sh`](../examples/10_directory_example.sh) |
| `dir_size` | [Docs & Examples](10-directory/dir_size.md) | [`10_directory_example.sh`](../examples/10_directory_example.sh) |
| `dir_is_empty` | [Docs & Examples](10-directory/dir_is_empty.md) | [`10_directory_example.sh`](../examples/10_directory_example.sh) |
| `dir_clean` | [Docs & Examples](10-directory/dir_clean.md) | [`10_directory_example.sh`](../examples/10_directory_example.sh) |
| `dir_tree` | [Docs & Examples](10-directory/dir_tree.md) | [`10_directory_example.sh`](../examples/10_directory_example.sh) |
| `dir_sync` | [Docs & Examples](10-directory/dir_sync.md) | [`10_directory_example.sh`](../examples/10_directory_example.sh) |
| `dir_watch` | [Docs & Examples](10-directory/dir_watch.md) | [`10_directory_example.sh`](../examples/10_directory_example.sh) |
| `dir_compare` | [Docs & Examples](10-directory/dir_compare.md) | [`10_directory_example.sh`](../examples/10_directory_example.sh) |