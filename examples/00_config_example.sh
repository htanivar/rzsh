#!/usr/bin/env zsh
# examples/00_config_example.sh
# Non-technical guide to initialization and global configurations.
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

# 1. Source the main config manager. This automatically imports all functions.
if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${0:A:h:h}" >&2
  export RZSH_DIR="${0:A:h:h}"
fi

source "${RZSH_DIR}/config/config.sh"

# 2. Run the initialization. This sets up default paths for logs, evidence, etc.
init_config

echo "=== System Initialized ==="
echo "RZSH framework folder: ${RZSH_DIR}"
echo "Project root folder:   ${PROJECT_ROOT}"
echo "Current log level:     ${LOG_LEVEL}"
echo "Logging folder path:   ${LOG_DIR}"
echo "Temporary files cache: ${EVIDENCE_DIR}"
