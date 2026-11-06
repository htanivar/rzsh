#!/usr/bin/env zsh
# examples/13_jwt_example.sh
# Non-technical guide to generating and validating JSON Web Tokens (JWT).
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${0:A:h:h}" >&2
  export RZSH_DIR="${0:A:h:h}"
fi

source "${RZSH_DIR}/config/config.sh"
init_config

payload='{"sub":"12345","name":"Alice","exp":2000000000}'
secret="my-super-secret-key"

# 1. Create a signed JWT
token=$(jwt_generate "${payload}" "${secret}")
echo "Generated signed JWT: ${token}"

# 2. Extract payload claims without key
decoded=$(jwt_decode "${token}")
echo "Payload claims: ${decoded}"

# 3. Retrieve specific claim property
subject=$(jwt_get_claim "${token}" ".name")
echo "Token Subject Name: ${subject}"

# 4. Verify token key and integrity
if jwt_verify "${token}" "${secret}"; then
  echo "Token signature matches key perfectly."
fi

# 5. Check if valid and active
if jwt_valid "${token}" "${secret}"; then
  echo "Token is valid and active (not expired)."
fi
