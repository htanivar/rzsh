#!/usr/bin/env zsh
# examples/07_user_actions_example.sh
# Non-technical guide to interactive input dialogs, menus, and selection loops.
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

source "$(dirname "$0")/../config/config.sh"
init_config

echo "=== Interactive User Dialog Demo ==="

# Provide default piped responses when executed non-interactively with empty stdin
if [[ ! -t 0 ]] && ! read -t 0 -k 1 2>/dev/null; then
  exec < <(printf "root\nsecret_api_key\ny\n2\n\nadmin@example.com\n")
fi

# 1. Read input with default fallback
username=$(read_input "Enter database user name" "root")
echo "Selected user: ${username}"

# 2. Prompt for passwords silently
secret_key=$(read_password "Enter API password (characters hidden): ")
echo "Password length entered: ${#secret_key} characters."

# 3. Confirmation choice
if confirm "Do you want to run updates?" "y"; then
  echo "Starting update..."
else
  echo "Update cancelled."
fi

# 4. Select from option list
target=$(select_option "Select environment" "development" "staging" "production")
echo "You chose: ${target}"

# 5. Wait for keypress
wait_for_enter "Press [Enter] to continue to validation loop..."

# 6. Reading text with validation loops
user_email=$(read_with_validation "Enter contact email" "validate_email")
echo "Verified email address: ${user_email}"
