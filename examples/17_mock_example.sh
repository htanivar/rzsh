#!/usr/bin/env zsh
# examples/17_mock_example.sh
# Breadcrumb: README.md -> GLOSSARY.md -> docs/17-mock.md -> examples/17_mock_example.sh -> tests/17-mock.test.sh
# Non-technical guide to generating mock data (strings, passwords, JWTs, Vault tokens,
# arrays, nested arrays, JSON) and mocking CLI/HTTP commands.
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${0:A:h:h}" >&2
  export RZSH_DIR="${0:A:h:h}"
fi

source "${RZSH_DIR}/config/config.sh"
init_config

echo "=== Mock Data Generators ==="
echo "String:       $(mock_string 8 "user_")"
echo "Alphanumeric: $(mock_alphanumeric 16)"
echo "Password:     $(mock_password 16 1)"
echo "Integer:      $(mock_int 100 999)"
echo "Boolean:      $(mock_bool)"
echo "UUID:         $(mock_uuid)"
echo "Email:        $(mock_email "acme.test")"
echo "Phone:        $(mock_phone)"
echo "Date:         $(mock_date "%Y-%m-%dT%H:%M:%SZ")"
echo "JWT:          $(mock_jwt "alice" "admin")"
echo "Vault Token:  $(mock_vault_token)"

local -a mock_emails
mock_array 3 "mock_emails" "email"
echo "Array (3):    ${mock_emails[*]}"
echo "Nested Array: $(mock_nested_array 2 3 "int")"
echo "Nested JSON:  $(mock_json 2 2)"
echo "User JSON:    $(mock_json_user)"

echo "\n=== Command & HTTP Mocking ==="
mock_command "git" "feature/mock-demo" 0
branch=$(git rev-parse --abbrev-ref HEAD)
echo "Mocked git branch: ${branch} (calls: $(mock_get_call_count "git"))"

mock_http_response '{"service":"billing","status":"ok"}' 200
res=$(http_get "https://api.example.com/health")
echo "HTTP status: $(check_status_code "${res}"), body: $(http_get_body "${res}")"

mock_restore_all
echo "All mocks restored."
