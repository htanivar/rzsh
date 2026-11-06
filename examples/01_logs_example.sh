#!/usr/bin/env zsh
# examples/01_logs_example.sh
# Non-technical guide to writing colored terminal text and files logs.
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${0:A:h:h}" >&2
  export RZSH_DIR="${0:A:h:h}"
fi

source "${RZSH_DIR}/config/config.sh"
init_config

# Initialize logs folder and log files
init_logging

# 1. Print formatted logs to terminal and file
log_info "This is a normal informational message (green)"
log_warn "This is a warning warning alert (yellow)"
log_error "This is an error notification (red)"
log_debug "This is a programmer debug message (only visible if LOG_LEVEL=DEBUG)"

# 2. Log steps for running a process
log_steps "Connecting to database"
log_steps "Downloading data"

# 3. Log sections for organizing terminal printout
log_section "System Setup Complete"

# 4. Run a command and log its execution automatically
log_command "echo 'Hello from log_command execution!'"
