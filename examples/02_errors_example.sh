#!/usr/bin/env zsh
# examples/02_errors_example.sh
# Non-technical guide to error trapping and temporary file cleanup.
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${0:A:h:h}" >&2
  export RZSH_DIR="${0:A:h:h}"
fi

source "${RZSH_DIR}/config/config.sh"
init_config

# Create a temporary scratch file
my_temp_file="/tmp/temp_user_demo.txt"
echo "secret credentials" > "${my_temp_file}"

# 1. Register file for auto-deletion
register_temp_file "${my_temp_file}"
echo "Registered temporary file: ${my_temp_file}"
echo "If this script fails or exits, the file will be deleted automatically."
cleanup_temp_files

# 2. Triggering error exit (uncomment to test termination)
# error_exit "Could not read user database!" 1
