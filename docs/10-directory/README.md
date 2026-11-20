# Directory Management — Function Index

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../10-directory.md) › **10-directory/** › [Runnable Example](../../examples/10_directory_example.sh) › [Tests](../../tests/10-directory.test.sh)

- **Source File:** [`functions/10-directory.sh`](../../functions/10-directory.sh)
- **Runnable Example:** [`examples/10_directory_example.sh`](../../examples/10_directory_example.sh)

| Function | Signature | Description |
| :--- | :--- | :--- |
| [`dir_exists`](dir_exists.md) | `dir_exists <dir>` | Checks if a path exists and is a directory. |
| [`dir_create`](dir_create.md) | `dir_create <dir>` | Creates a directory, including any necessary parent directories. |
| [`dir_delete`](dir_delete.md) | `dir_delete <dir> [option]` | Deletes a directory recursively. Requires confirmation unless --force or -f is passed. |
| [`dir_copy`](dir_copy.md) | `dir_copy <source> <dest>` | Recursively copies a directory to a destination. |
| [`dir_move`](dir_move.md) | `dir_move <source> <dest>` | Moves or renames a directory to a ask destination. |
| [`dir_list`](dir_list.md) | `dir_list <dir> [pattern=*]` | Lists files and folders directly inside a directory that match a pattern. |
| [`dir_size`](dir_size.md) | `dir_size <dir>` | Calculates the total size of all files in a directory in bytes. |
| [`dir_is_empty`](dir_is_empty.md) | `dir_is_empty <dir>` | Checks if a directory is empty. |
| [`dir_clean`](dir_clean.md) | `dir_clean <dir>` | Deletes all files and directories inside a directory without deleting the directory itself. |
| [`dir_tree`](dir_tree.md) | `dir_tree <dir>` | Prints a tree-like visualization of a directory structure. |
| [`dir_sync`](dir_sync.md) | `dir_sync <source> <dest>` | Synchronizes the contents of a source directory to a destination directory. |
| [`dir_watch`](dir_watch.md) | `dir_watch <dir> <callback> [iterations=5]` | Watches a directory for file system changes and runs a callback function. |
| [`dir_compare`](dir_compare.md) | `dir_compare [options] <dir1> <dir2>` | Recursively compares two directories and generates a Markdown report of added, removed, modified, and identical files. |
