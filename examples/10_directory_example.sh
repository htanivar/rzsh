#!/usr/bin/env zsh
# examples/10_directory_example.sh
# Non-technical guide to directory tree sync, creation, lists, and file watchers.
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${0:A:h:h}" >&2
  export RZSH_DIR="${0:A:h:h}"
fi

source "${RZSH_DIR}/config/config.sh"
init_config

my_dir="${PROJECT_ROOT}/logs/temp_demo_dir"

# 1. Create directory recursively
dir_create "${my_dir}"
echo "Created directory path: ${my_dir}"

# 2. Add some placeholder files
touch "${my_dir}/note1.txt" "${my_dir}/note2.log"

# 3. List folder matching a pattern
echo "Filtered files (*.txt):"
dir_list "${my_dir}" "*.txt"

# 4. Sync directory to backup location
backup_dir="${PROJECT_ROOT}/logs/temp_demo_dir_backup"
dir_sync "${my_dir}" "${backup_dir}"
echo "Synchronized directory contents to: ${backup_dir}"

# 5. Clean up directories
dir_delete "${my_dir}" "--force"
dir_delete "${backup_dir}" "--force"
echo "Cleaned up test directories."
