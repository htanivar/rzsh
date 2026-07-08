#!/usr/bin/env zsh
# examples/01_logs_example.sh
# Non-technical guide to writing colored terminal text and files logs.

source "$(dirname "$0")/../config/config.sh"
init_config

# Initialize logs folder and log files
init_logging

# 1. Print formatted logs to terminal and file
log_info "This is a normal informational message (green)"
log_warn "This is a warning warning alert (yellow)"
log_error "This is an error notification (red)"
log_debug "This is a programmer debug message (only visible if LOG_LEVEL=DEBUG)"

# 2. Log steps for running a process
log_step 1 "Connecting to database"
log_step 2 "Downloading data"

# 3. Log sections for organizing terminal printout
log_section "System Setup Complete"

# 4. Run a command and log its execution automatically
log_command "echo 'Hello from log_command execution!'"
