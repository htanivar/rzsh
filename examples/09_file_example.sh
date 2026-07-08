#!/usr/bin/env zsh
# examples/09_file_example.sh
# Non-technical guide to file operations, backing up, size, and search text.

source "$(dirname "$0")/../config/config.sh"
init_config

local my_file="${PROJECT_ROOT}/logs/notes.txt"

# 1. Write text content (interprets newlines)
file_write "${my_file}" "line 1: initial text\nline 2: second text"
echo "Wrote initial content to: ${my_file}"

# 2. Append text content
file_append "${my_file}" "line 3: appended text"

# 3. Read size in bytes
local size=$(file_get_size "${my_file}")
echo "File size: ${size} bytes."

# 4. Run backups
echo "Creating backup..."
file_backup_and_restore "backup" "${my_file}"

# 5. Cryptographic digests
local sha=$(file_hash "${my_file}" "sha256")
echo "SHA-256 Checksum: ${sha}"

# 6. Read parts or search patterns
echo "File content match search:"
file_grep "${my_file}" "appended"
