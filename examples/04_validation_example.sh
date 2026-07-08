#!/usr/bin/env zsh
# examples/04_validation_example.sh
# Non-technical guide to checking input format validity (emails, urls, dates, numbers).

source "$(dirname "$0")/../config/config.sh"
init_config

# 1. Required input check
if validate_required "some text"; then
  echo "Validation passed: input is not empty."
fi

# 2. In list check
if validate_in_list "prod" "dev,staging,prod"; then
  echo "Validation passed: 'prod' is an allowed environment choice."
fi

# 3. Numeric check
if validate_is_number "42"; then
  echo "Validation passed: '42' is a valid integer."
fi

# 4. Email check
if validate_email "support@google.com"; then
  echo "Validation passed: 'support@google.com' is a valid email format."
fi

# 5. URL check
if validate_url "https://news.google.com"; then
  echo "Validation passed: website link is valid."
fi

# 6. Command exist check
if validate_command_exists "ls"; then
  echo "Validation passed: 'ls' command exists on this system."
fi

# 7. Date check
if validate_date "2026-07-08"; then
  echo "Validation passed: '2026-07-08' is a valid calendar date format."
fi

# 8. JWT format check
if validate_jwt "header.payload.signature"; then
  echo "Validation passed: token matches JWT structure."
fi

# 9. JSON validation check
if validate_json '{"user": "alice"}'; then
  echo "Validation passed: string is valid JSON."
fi
