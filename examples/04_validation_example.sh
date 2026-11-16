#!/usr/bin/env zsh
# examples/04_validation_example.sh
# Breadcrumb: README.md -> GLOSSARY.md -> docs/04-validation.md -> examples/04_validation_example.sh -> tests/04-validation.test.sh
# Non-technical guide to checking input format validity (emails, urls, dates, numbers).
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${0:A:h:h}" >&2
  export RZSH_DIR="${0:A:h:h}"
fi

source "${RZSH_DIR}/config/config.sh"
init_config

# 1. Required input check (positive & negative)
if validate_required "some text"; then
  echo "Validation passed: input is not empty."
fi
if ! validate_required "" "Username is required" 2>/dev/null; then
  echo "Negative check passed: empty input was rejected."
fi

# 2. In list check (comma-separated, space-separated, and negative)
role="admin"
if validate_in_list "${role}" "admin,user,guest"; then
  echo "Validation passed: '${role}' is an allowed role."
fi

invalid_role="moderator"
if validate_in_list "${invalid_role}" "admin,user,guest"; then
  echo "Unexpected: '${invalid_role}' should not be allowed."
else
  echo "Negative check passed: '${invalid_role}' is not in (admin,user,guest)."
fi

env_choice="staging"
validate_in_list "${env_choice}" "dev staging prod" && echo "Validation passed: '${env_choice}' is in space-separated list."

# 3. File & directory existence checks (positive & negative)
if validate_file_exists "${RZSH_DIR}/config/config.sh"; then
  echo "Validation passed: config.sh exists."
fi
if ! validate_file_exists "${RZSH_DIR}/config/does_not_exist.sh"; then
  echo "Negative check passed: missing file detected."
fi

if validate_directory_exists "${RZSH_DIR}/functions"; then
  echo "Validation passed: functions directory exists."
fi
if ! validate_directory_exists "${RZSH_DIR}/nonexistent_dir"; then
  echo "Negative check passed: missing directory detected."
fi

# 4. Numeric check (positive, negative number, decimal, and non-numeric)
if validate_is_number "42"; then
  echo "Validation passed: '42' is a valid integer."
fi
if validate_is_number "-12.5"; then
  echo "Validation passed: '-12.5' is a valid signed decimal."
fi
if ! validate_is_number "not_a_number"; then
  echo "Negative check passed: 'not_a_number' was rejected."
fi

# 5. Email check (positive & negative)
if validate_email "support@google.com"; then
  echo "Validation passed: 'support@google.com' is a valid email format."
fi
if ! validate_email "invalid-email@"; then
  echo "Negative check passed: 'invalid-email@' was rejected."
fi

# 6. URL check (positive & negative)
if validate_url "https://news.google.com"; then
  echo "Validation passed: website link is valid."
fi
if ! validate_url "news.google.com"; then
  echo "Negative check passed: URL without http/https scheme was rejected."
fi

# 7. Command exist check (positive & negative)
if validate_command_exists "ls"; then
  echo "Validation passed: 'ls' command exists on this system."
fi
if ! validate_command_exists "nonexistent_cmd_xyz"; then
  echo "Negative check passed: missing command 'nonexistent_cmd_xyz' detected."
fi

# 8. Date check (positive & negative)
if validate_date "2026-07-08"; then
  echo "Validation passed: '2026-07-08' is a valid calendar date format."
fi
if ! validate_date "invalid-date"; then
  echo "Negative check passed: 'invalid-date' was rejected."
fi

# 9. JWT format check (positive & negative)
if validate_jwt "header.payload.signature"; then
  echo "Validation passed: token matches JWT structure."
fi
if ! validate_jwt "malformed_token"; then
  echo "Negative check passed: malformed JWT token was rejected."
fi

# 10. JSON validation check (positive & negative)
if validate_json '{"user": "alice"}'; then
  echo "Validation passed: string is valid JSON."
fi
if ! validate_json '{"user": broken}'; then
  echo "Negative check passed: invalid JSON string was rejected."
fi
