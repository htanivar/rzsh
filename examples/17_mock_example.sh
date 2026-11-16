#!/usr/bin/env zsh
# examples/17_mock_example.sh
# Breadcrumb: README.md -> GLOSSARY.md -> docs/17-mock.md -> examples/17_mock_example.sh -> tests/17-mock.test.sh
# Non-technical guide to mocking commands, HTTP calls, and asserting invocations.
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${0:A:h:h}" >&2
  export RZSH_DIR="${0:A:h:h}"
fi

source "${RZSH_DIR}/config/config.sh"
init_config

echo "=== Command & HTTP Mocking Examples ==="

# 1. Mock a CLI command (e.g., git)
mock_command "git" "feature/mock-demo" 0
branch=$(git rev-parse --abbrev-ref HEAD)
echo "Mocked git branch: ${branch}"
echo "git call count:    $(mock_get_call_count "git")"
echo "git last args:     $(mock_get_last_args "git")"

# 2. Mock an HTTP call via curl
mock_http_response '{"service":"billing","status":"ok"}' 200
res=$(http_get "https://api.example.com/health")
echo "HTTP status code:  $(check_status_code "${res}")"
echo "HTTP body:         $(http_get_body "${res}")"

if mock_was_called "curl" 1; then
  echo "Verified: curl was called exactly 1 time."
fi

# 3. Restore all mocks cleanly
mock_restore_all
echo "All mocks restored."
