#!/usr/bin/env zsh
# examples/02_errors_example.sh
# Non-technical guide to error trapping and temporary file cleanup.

source "$(dirname "$0")/../config/config.sh"
init_config

# Create a temporary scratch file
local my_temp_file="/tmp/temp_user_demo.txt"
echo "secret credentials" > "${my_temp_file}"

# 1. Register file for auto-deletion
register_temp_file "${my_temp_file}"
echo "Registered temporary file: ${my_temp_file}"
echo "If this script fails or exits, the file will be deleted automatically."

# 2. Triggering error exit (uncomment to test termination)
# error_exit "Could not read user database!" 1
