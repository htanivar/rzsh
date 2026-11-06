#!/usr/bin/env zsh
# scripts/02-ssh/getJwt.sh
# Retrieves the machine identity JWT token by running ~/.getId() or falls back to a mock/simulated JWT.
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

# Advise if RZSH_DIR is not set, and fallback to local framework directory
if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${0:A:h:h:h}" >&2
  export RZSH_DIR="${0:A:h:h:h}"
fi

# Source framework config and functions via RZSH_DIR
source "${RZSH_DIR}/config/config.sh"
init_config

ID_SCRIPT="${HOME}/.getId"

if [[ -x "${ID_SCRIPT}" ]]; then
  # Execute the identity script to retrieve the actual JWT
  jwt=$("${ID_SCRIPT}")
  validate_required "${jwt}" "Identity script returned an empty JWT" || error_exit "Empty JWT returned"
  echo "${jwt}"
else
  # Fallback: using pre-defined logging function
  log_warn "Identity script ${ID_SCRIPT} not found/executable. Using fallback mock JWT."
  # A realistic looking mock JWT structure: header.payload.signature
  echo "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzc2gtaWRlbnRpdHkiLCJzdWIiOiJtYWNoaW5lLTEyMyIsImV4cCI6OTk5OTk5OTk5OX0.mock_signature_from_ssh_key"
fi
