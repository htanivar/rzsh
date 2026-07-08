# functions/07-user-actions.sh

# Protect against double sourcing
if [[ -n "${_USER_ACTIONS_SH_SOURCED:-}" ]]; then
  return 0
fi
readonly _USER_ACTIONS_SH_SOURCED=1

# Ensure config is sourced if available
if [[ -f "${PROJECT_ROOT:-.}/config/config.sh" ]]; then
  source "${PROJECT_ROOT:-.}/config/config.sh"
fi

# /**
#  * @function read_input
#  * @description Prompts the user for input. If the user presses enter without typing anything, returns the default value.
#  * @param {string} prompt - The prompt message.
#  * @param {string} [default] - Default value if input is empty.
#  * @return {string} The input value or default.
#  * @example
#  *   local name
#  *   name=$(read_input "Enter your name" "Guest")
#  */
read_input() {
  local prompt="$1"
  local default="$2"
  local response
  
  if [[ -n "${default}" ]]; then
    printf "%s [%s]: " "${prompt}" "${default}" >&2
  else
    printf "%s: " "${prompt}" >&2
  fi
  
  read -r response
  
  if [[ -z "${response}" ]]; then
    echo "${default}"
  else
    echo "${response}"
  fi
}

# /**
#  * @function read_password
#  * @description Prompts the user for a password or sensitive input silently (without echoing input).
#  * @param {string} prompt - The prompt message.
#  * @return {string} The password entered.
#  * @example
#  *   local pass
#  *   pass=$(read_password "Enter API Key")
#  */
read_password() {
  local prompt="$1"
  local response
  
  printf "%s: " "${prompt}" >&2
  read -s -r response
  echo "" >&2
  echo "${response}"
}

# /**
#  * @function confirm
#  * @description Prompts the user for confirmation (yes/no).
#  * @param {string} prompt - The prompt message.
#  * @param {string} [default=n] - Default option 'y' (yes) or 'n' (no).
#  * @return {number} 0 if confirmed (yes), 1 otherwise (no).
#  * @example
#  *   if confirm "Do you want to deploy?"; then
#  *     deploy
#  *   fi
#  */
confirm() {
  local prompt="$1"
  local default="${2:-n}"
  local response
  
  if [[ "${default}" =~ ^[Yy]$ ]]; then
    printf "%s [Y/n]: " "${prompt}" >&2
  else
    printf "%s [y/N]: " "${prompt}" >&2
  fi
  
  read -r response
  response="${response:l}"
  
  if [[ -z "${response}" ]]; then
    response="${default:l}"
  fi
  
  if [[ "${response}" == "y" || "${response}" == "yes" ]]; then
    return 0
  else
    return 1
  fi
}

# /**
#  * @function select_option
#  * @description Displays a list of options and prompts the user to select one.
#  * @param {string} prompt - Prompt explanation.
#  * @param {string} options - Space-separated list of options.
#  * @return {string} The selected option string.
#  * @example
#  *   local env
#  *   env=$(select_option "Select environment" "development staging production")
#  */
select_option() {
  local prompt="$1"
  local options_str="$2"
  local -a options
  options=( ${(s: :)${options_str//,/ }} )
  
  printf "%s\n" "${prompt}" >&2
  local i
  for (( i = 1; i <= ${#options}; i++ )); do
    printf "  %d) %s\n" "${i}" "${options[i]}" >&2
  done
  
  local choice
  while true; do
    printf "Select option (1-%d): " "${#options}" >&2
    read -r choice
    if [[ "${choice}" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#options} )); then
      echo "${options[choice]}"
      return 0
    fi
    printf "Invalid selection. Please try again.\n" >&2
  done
}

# /**
#  * @function wait_for_enter
#  * @description Pauses script execution and waits for the user to press Enter.
#  * @param {string} [prompt="Press Enter to continue..."] - Prompt message.
#  * @return {void}
#  * @example
#  *   wait_for_enter "Confirm everything is okay and press Enter..."
#  */
wait_for_enter() {
  local prompt="${1:-Press Enter to continue...}"
  printf "%s" "${prompt}" >&2
  read -r
}

# /**
#  * @function read_with_validation
#  * @description Repeatedly prompts the user for input until it successfully validates against a validation function.
#  * @param {string} prompt - Prompt message.
#  * @param {string} validation_func - The name of the Zsh validation function to run against input.
#  * @return {string} The validated user input.
#  * @example
#  *   local num
#  *   num=$(read_with_validation "Enter a number" "validate_is_number")
#  */
read_with_validation() {
  local prompt="$1"
  local val_func="$2"
  local response
  
  while true; do
    printf "%s: " "${prompt}" >&2
    read -r response
    if "${val_func}" "${response}" &>/dev/null; then
      echo "${response}"
      return 0
    fi
    printf "Validation failed. Please try again.\n" >&2
  done
}
