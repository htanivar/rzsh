#!/usr/bin/env zsh
# examples/00_config_example.sh
# Non-technical guide to initialization and global configurations.

# 1. Source the main config manager. This automatically imports all functions.
source "$(dirname "$0")/../config/config.sh"

# 2. Run the initialization. This sets up default paths for logs, evidence, etc.
init_config

echo "=== System Initialized ==="
echo "Project root folder:  ${PROJECT_ROOT}"
echo "Current log level:     ${LOG_LEVEL}"
echo "Logging folder path:  ${LOG_DIR}"
echo "Temporary files cache: ${EVIDENCE_DIR}"
