#!/usr/bin/env zsh
# README.sh
# Documentation and command-line reference manual for the modular Zsh scripting framework.

# Protect against double sourcing
if [[ -n "${_README_SH_SOURCED:-}" ]]; then
  return 0
fi
readonly _README_SH_SOURCED=1

# Color definitions for rich terminal aesthetics
RESET="\e[0m"
BOLD="\e[1m"
UNDERLINE="\e[4m"
COLOR_HEADER="\e[38;5;39m"   # Blue
COLOR_MODULE="\e[38;5;214m"  # Orange/Gold
COLOR_FUNC="\e[38;5;82m"     # Green
COLOR_TEXT="\e[38;5;253m"    # Off-white
COLOR_CODE="\e[38;5;244m"    # Grey background/text
COLOR_FAQ="\e[38;5;207m"     # Pink/Magenta
COLOR_WARN="\e[38;5;196m"    # Red

print_header() {
  local title="$1"
  echo ""
  echo -e "${BOLD}${COLOR_HEADER}================================================================================${RESET}"
  echo -e "${BOLD}${COLOR_HEADER}  ${title}${RESET}"
  echo -e "${BOLD}${COLOR_HEADER}================================================================================${RESET}"
}

print_section() {
  local sec_name="$1"
  echo ""
  echo -e "${BOLD}${UNDERLINE}${COLOR_MODULE}${sec_name}${RESET}"
}

print_func() {
  local name="$1"
  local desc="$2"
  local usage="$3"
  echo -e "  ${BOLD}${COLOR_FUNC}${name}${RESET}"
  echo -e "    ${COLOR_TEXT}${desc}${RESET}"
  echo -e "    ${COLOR_CODE}Usage: ${usage}${RESET}"
  echo ""
}

print_faq() {
  local question="$1"
  local answer="$2"
  echo -e "  ${BOLD}${COLOR_FAQ}Q: ${question}${RESET}"
  echo -e "  ${COLOR_TEXT}A: ${answer}${RESET}"
  echo ""
}

show_readme() {
  print_header "ZSH MODULAR SCRIPTING FRAMEWORK MANUAL"
  
  echo -e "${COLOR_TEXT}Welcome to the Modular Zsh Scripting Framework. This framework consists of 14 separate"
  echo -e "functional modules plus a global configuration manager. It is designed to be highly modular,"
  echo -e "performant, and structurally robust using native Zsh features.${RESET}"

  print_section "GETTING STARTED (USABLES)"
  echo -e "To use this framework in any of your scripts, source the configuration manager and initialize it:"
  echo ""
  echo -e "  ${COLOR_CODE}# Sourcing the config and function modules${RESET}"
  echo -e "  ${COLOR_CODE}source ./config/config.sh${RESET}"
  echo -e "  ${COLOR_CODE}init_config${RESET}"
  echo -e "  ${COLOR_CODE}source ./functions/01-logs.sh${RESET}"
  echo -e "  ${COLOR_CODE}source ./functions/02-errors.sh${RESET}"
  echo -e "  ${COLOR_CODE}# ... source other modules as needed${RESET}"

  print_section "MODULES & AVAILABLE FUNCTIONS"

  # Module 00: Config
  echo -e "${BOLD}${COLOR_MODULE}00. Global Configuration (config/config.sh)${RESET}"
  print_func "init_config" \
    "Initializes the framework global configuration variables, setting defaults if not overridden by the env." \
    "init_config"

  # Module 01: Logs
  echo -e "${BOLD}${COLOR_MODULE}01. Logging Utility (functions/01-logs.sh)${RESET}"
  print_func "init_logging" \
    "Initializes logging directory and configuration." \
    "init_logging"
  print_func "log_info / log_warn / log_error / log_debug" \
    "Prints formatted colored log messages to stdout and the log file." \
    "log_info \"Operation completed successfully.\""
  print_func "log_command" \
    "Runs a command, captures and logs its stdout/stderr, and returns the command's exit code." \
    "log_command \"git status\""

  # Module 02: Errors
  echo -e "${BOLD}${COLOR_MODULE}02. Error Handling (functions/02-errors.sh)${RESET}"
  print_func "error_exit" \
    "Logs a fatal error message with stack trace information, runs registered cleanup, and exits." \
    "error_exit \"Database connection failed\" 500"
  print_func "register_temp_file" \
    "Registers a temporary file/folder to be automatically deleted upon script exit." \
    "register_temp_file \"/tmp/scratch.txt\""

  # Module 03: Navigation
  echo -e "${BOLD}${COLOR_MODULE}03. File Navigation & Git Checks (functions/03-navigation.sh)${RESET}"
  print_func "get_current_directory / dir_up" \
    "Calculates directories relative to the executing shell context." \
    "dir_up 2"
  print_func "is_inside_git_repo" \
    "Returns 0 if the current working directory is inside a Git repository." \
    "if is_inside_git_repo; then ... fi"

  # Module 04: Validation
  echo -e "${BOLD}${COLOR_MODULE}04. Input & Format Validation (functions/04-validation.sh)${RESET}"
  print_func "validate_email" \
    "Validates that a string matches basic email structure." \
    "validate_email \"user@example.com\""
  print_func "validate_jwt" \
    "Checks if a token structurally matches a 3-part base64url-encoded JWT format." \
    "validate_jwt \"\${token}\""

  # Module 05: Git
  echo -e "${BOLD}${COLOR_MODULE}05. Git Operations (functions/05-git.sh)${RESET}"
  print_func "git_get_current_branch" \
    "Outputs the name of the current active Git branch." \
    "local branch=\$(git_get_current_branch)"
  print_func "git_is_clean" \
    "Returns 0 if there are no uncommitted changes in the Git working copy." \
    "git_is_clean || error_exit \"Working copy is dirty\""

  # Module 06: Curl
  echo -e "${BOLD}${COLOR_MODULE}06. HTTP Client Client Wrapper (functions/06-curl.sh)${RESET}"
  print_func "http_get / http_post" \
    "Executes curl request, appending HTTP status code to the output body." \
    "local res=\$(http_get \"https://api.example.com/users\")"
  print_func "http_get_with_retry" \
    "Retries an HTTP GET request up to N times until a 2xx success is returned." \
    "http_get_with_retry \"https://api.example.com/status\" 3"

  # Module 07: User Actions
  echo -e "${BOLD}${COLOR_MODULE}07. Interactive Prompts (functions/07-user-actions.sh)${RESET}"
  print_func "read_password" \
    "Prompts the user for sensitive input, hiding terminal characters." \
    "local db_pass=\$(read_password \"Enter DB password: \")"
  print_func "select_option" \
    "Renders an interactive menu allowing the user to select from a list of options." \
    "local choice=\$(select_option \"Select environment\" \"dev\" \"staging\" \"prod\")"

  # Module 08: Datetime
  echo -e "${BOLD}${COLOR_MODULE}08. Time & Duration (functions/08-datetime.sh)${RESET}"
  print_func "date_now" \
    "Prints the current time in the standard DATE_FORMAT." \
    "local today=\$(date_now)"
  print_func "date_diff" \
    "Calculates the absolute difference in seconds between two timestamp strings." \
    "local diff_seconds=\$(date_diff \"2026-07-01 10:00:00\" \"2026-07-01 11:30:00\")"

  # Module 09: File
  echo -e "${BOLD}${COLOR_MODULE}09. File Utilities (functions/09-file.sh)${RESET}"
  print_func "file_write / file_append" \
    "Writes or appends content to target file (interprets escapes like \\n)." \
    "file_write \"log.txt\" \"line1\\nline2\""
  print_func "file_get_size" \
    "Retrieves the size of a file in bytes using native zsh/stat if loaded." \
    "local bytes=\$(file_get_size \"archive.tar.gz\")"

  # Module 10: Directory
  echo -e "${BOLD}${COLOR_MODULE}10. Directory Management (functions/10-directory.sh)${RESET}"
  print_func "dir_list" \
    "Lists files in a folder directly matching a specified glob pattern." \
    "local files=\$(dir_list \"/var/log\" \"*.log\")"
  print_func "dir_watch" \
    "Polls a directory and triggers a callback function when any changes occur." \
    "dir_watch \"./src\" \"my_rebuild_callback\" 5"

  # Module 11: String
  echo -e "${BOLD}${COLOR_MODULE}11. String Formatting (functions/11-string.sh)${RESET}"
  print_func "str_trim" \
    "Trims leading and trailing whitespace from a string." \
    "local clean=\$(str_trim \"  hello  \")"
  print_func "str_split / str_join" \
    "Splits a string by delimiter or joins arguments using a custom character." \
    "local csv=\$(str_join \",\" \"val1\" \"val2\")"

  # Module 12: SSH & SCP Client
  echo -e "${BOLD}${COLOR_MODULE}12. SSH & SCP Client (functions/12-ssh.sh)${RESET}"
  print_func "ssh_is_reachable" \
    "Checks if the SSH service on a remote host is reachable." \
    "ssh_is_reachable \"10.0.0.5\" 22 2"
  print_func "ssh_exec / ssh_scp_up / ssh_scp_down" \
    "Executes remote commands or transfers files via SSH/SCP (identity/password)." \
    "ssh_exec \"user\" \"host\" \"uname -a\""

  # Module 13: JWT
  echo -e "${BOLD}${COLOR_MODULE}13. JSON Web Tokens (functions/13-jwt.sh)${RESET}"
  print_func "jwt_generate / jwt_decode" \
    "Creates a signed HS256 JWT, or extracts the payload without verifying." \
    "local token=\$(jwt_generate '{\"sub\":\"123\"}' \"my-secret\")"
  print_func "jwt_verify / jwt_valid" \
    "Verifies signature matches key, and checks if expiration ('exp') is valid." \
    "jwt_valid \"\${token}\" \"my-secret\" && echo \"Valid!\""

  # Module 14: JQ JSON Parser
  echo -e "${BOLD}${COLOR_MODULE}14. JSON Parsing & JQ (functions/14-jq.sh)${RESET}"
  print_func "json_get_value" \
    "Queries a value at a specified path in a JSON string (using jq)." \
    "local user=\$(json_get_value \"\${json}\" \".user.name\")"
  print_func "json_set_value" \
    "Sets or modifies a value at a specified JSON path." \
    "local new_json=\$(json_set_value \"\${json}\" \".active\" \"true\")"

  # Module 99: Evidences
  echo -e "${BOLD}${COLOR_MODULE}99. Evidence Collector (functions/99-evidences.sh)${RESET}"
  print_func "init_evidence" \
    "Prepares a timestamped directory to store diagnostic/incident logs." \
    "init_evidence"
  print_func "collect_environment_evidence / collect_git_evidence / collect_network_evidence" \
    "Dumps environment variables, git history, system, and network data to session artifacts." \
    "collect_environment_evidence"
  print_func "evidence_to_markdown" \
    "Synthesizes all gathered session details into a formatted Markdown report." \
    "evidence_to_markdown > report.md"

  print_section "FREQUENTLY ASKED QUESTIONS (FAQ)"

  print_faq "Why are all JSDoc comment lines prepended with '# '?" \
    "In Zsh, by default, '/**' is parsed as a recursive globbing operator. Placing block comments\n     without prepending comment characters causes Zsh to evaluate them as file patterns, resulting\n     in parser errors like 'no matches found' or permission denials."

  print_faq "Why did you rename 'local path' to 'local json_path'?" \
    "In Zsh, 'path' is a special built-in array tied to the 'PATH' environment variable. Declaring\n     'local path' and assigning a value like '.user.name' replaces the command path search list,\n     preventing the shell from finding command line binaries like 'jq'."

  print_faq "Why did you rename 'local status' to 'local exit_code'?" \
    "In Zsh, 'status' is a read-only variable aliased to '$?'. Declaring 'local status' throws\n     a shell error: 'read-only variable: status'."

  print_faq "How do I run the unit tests?" \
    "You can run the entire test runner suite using the test script:\n     PATH=\"/home/ubuntu/.local/bin:\$PATH\" ./test.sh"

  print_section "POSSIBLE FUTURE IMPROVEMENTS"
  echo -e "  1. ${BOLD}Native Configuration Parsing:${RESET} Add native parser support for TOML and YAML configurations"
  echo -e "     to remove external library dependencies for basic config loads."
  echo -e "  2. ${BOLD}Enhanced Console Indicators:${RESET} Introduce animated spinners and customizable progress bar indicators"
  echo -e "     in '07-user-actions.sh' for longer-running async processes."
  echo -e "  3. ${BOLD}Subprocess Logging Rotation:${RESET} Add automatic daemonized backgroud log rotation inside '01-logs.sh'"
  echo -e "     to prevent log files from growing continuously."
  echo -e "  4. ${BOLD}Mock/Offline Testing Suite:${RESET} Fully detach network dependencies in the Curl test suite by launching"
  echo -e "     a lightweight, local background netcat or python web server during execution."
  echo ""
}

# Execute help display if run directly
if [[ "${(%):-%N}" == "${0}" || "${0}" == *"help.sh"* ]]; then
  show_readme
fi
