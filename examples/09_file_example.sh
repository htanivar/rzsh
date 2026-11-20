#!/usr/bin/env zsh
# examples/09_file_example.sh
# Breadcrumb: README.md -> GLOSSARY.md -> docs/09-file.md -> examples/09_file_example.sh -> tests/09-file.test.sh
# Non-technical guide to file operations, backing up, size, and search text.
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${0:A:h:h}" >&2
  export RZSH_DIR="${0:A:h:h}"
fi

source "${RZSH_DIR}/config/config.sh"
init_config
init_logging

my_file="${PROJECT_ROOT}/logs/notes.txt"

# 1. Write text content (interprets newlines)
file_write "${my_file}" "line 1: initial text\nline 2: second text"
echo "Wrote initial content to: ${my_file}"

# 2. Append text content
file_append "${my_file}" "line 3: appended text"

# 3. Read size in bytes
size=$(file_get_size "${my_file}")
echo "File size: ${size} bytes."

# 4. Run backups
echo "Creating backup..."
backup_file=$(file_backup_and_restore "backup" "${my_file}")
echo "Created backup: ${backup_file}"

# 5. Cryptographic digests
sha=$(file_hash "${my_file}" "sha256")
echo "SHA-256 Checksum: ${sha}"

# 6. Read parts or search patterns
echo "File content match search:"
file_grep "${my_file}" "appended"

# 7. Read file into an array and loop over each line
local -a file_lines
file_read_to_array "${my_file}" "file_lines" 1
echo "Looping over ${#file_lines[@]} lines from ${my_file}:"
local idx=1
for line in "${file_lines[@]}"; do
  echo "  [${idx}] ${line}"
  (( idx++ ))
done

# 8. Compare two files
other_file="${PROJECT_ROOT}/logs/notes_v2.txt"
file_write "${other_file}" "line 1: initial text\nline 2: updated text\nline 3: appended text"
if ! file_equals "${my_file}" "${other_file}"; then
  echo "Files differ; generating comparison report:"
  file_compare "${my_file}" "${other_file}" || true
fi

rm -f "${my_file}" "${other_file}" "${backup_file}"
