# File Operations — Function Index

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../09-file.md) › **09-file/** › [Runnable Example](../../examples/09_file_example.sh) › [Tests](../../tests/09-file.test.sh)

- **Source File:** [`functions/09-file.sh`](../../functions/09-file.sh)
- **Runnable Example:** [`examples/09_file_example.sh`](../../examples/09_file_example.sh)

| Function | Signature | Description |
| :--- | :--- | :--- |
| [`file_exists`](file_exists.md) | `file_exists <file>` | Checks if a path exists and points to a regular file. |
| [`file_read`](file_read.md) | `file_read <file>` | Reads and prints the entire contents of a file to stdout. |
| [`file_read_to_array`](file_read_to_array.md) | `file_read_to_array <file> [array_name=FILE_LINES] [skip_empty=0]` | Reads a file line-by-line into a Zsh array variable for iteration/looping. |
| [`file_write`](file_write.md) | `file_write <file> <content>` | Writes the specified content to a file, overwriting its previous contents. |
| [`file_append`](file_append.md) | `file_append <file> <content>` | Appends the specified content to the end of a file. |
| [`file_copy`](file_copy.md) | `file_copy <source> <dest>` | Copies a file from source to destination. |
| [`file_move`](file_move.md) | `file_move <source> <dest>` | Moves or renames a file from source to destination. |
| [`file_delete`](file_delete.md) | `file_delete <file> [option]` | Deletes a file. Requires confirmation unless --force or -f is passed. |
| [`file_get_size`](file_get_size.md) | `file_get_size <file>` | Prints the size of a file in bytes. |
| [`file_get_permissions`](file_get_permissions.md) | `file_get_permissions <file>` | Returns the permissions of a file in octal format (e.g. 644). |
| [`file_set_permissions`](file_set_permissions.md) | `file_set_permissions <file> <perms>` | Changes the permissions of a file. |
| [`file_get_owner`](file_get_owner.md) | `file_get_owner <file>` | Prints the username of the owner of a file. |
| [`file_get_group`](file_get_group.md) | `file_get_group <file>` | Prints the group name of a file. |
| [`file_backup`](file_backup.md) | `file_backup <file>` | Creates a backup copy of a file with a timestamp suffix. |
| [`file_restore`](file_restore.md) | `file_restore <backup_file>` | Restores a file from a timestamped backup path. |
| [`file_backup_and_restore`](file_backup_and_restore.md) | `file_backup_and_restore <action> <file> [backup_path]` | High-level wrapper to backup or restore files. |
| [`file_hash`](file_hash.md) | `file_hash <file> [algorithm=sha256]` | Calculates the cryptographic hash of a file. |
| [`file_tail`](file_tail.md) | `file_tail <file> [lines=10]` | Outputs the last N lines of a file. |
| [`file_head`](file_head.md) | `file_head <file> [lines=10]` | Outputs the first N lines of a file. |
| [`file_grep`](file_grep.md) | `file_grep <file> <pattern>` | Searches for a pattern in a file. |
| [`file_equals`](file_equals.md) | `file_equals <file1> <file2>` | Checks whether two files have identical byte-for-byte contents. |
| [`file_compare`](file_compare.md) | `file_compare [options] <file1> <file2>` | Compares two files (size, SHA-256 hash, line count, unified diff) and prints/writes a Markdown report. |
