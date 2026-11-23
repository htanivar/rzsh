#!/usr/bin/env zsh
# scripts/02-ssh/sshTunnel.sh
# Establishes an SSH local port-forwarding tunnel between local machine and a VPS.
# Supports both interactive prompts and non-interactive CLI flags (suitable for aliases).
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

# Advise if RZSH_DIR is not set, and fallback to local framework directory
if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${0:A:h:h:h}" >&2
  export RZSH_DIR="${0:A:h:h:h}"
fi

# Source framework config and functions via RZSH_DIR
source "${RZSH_DIR}/config/config.sh"
init_config || {
  printf "Error: Failed to initialize framework configuration.\n" >&2
  exit 1
}

# Print CLI usage instructions
usage() {
  cat <<EOF
Usage: ${0:t} [OPTIONS]

Establishes an SSH local port-forwarding tunnel (-L local_port:remote_host:remote_port)
using rzsh framework functions. Runs interactively when required options are omitted,
or non-interactively when all required options are provided (ideal for aliases).

Options:
  -H, --host <host>          VPS / SSH server IP or hostname (required)
  -p, --port <port>          SSH server port (default: 22)
  -u, --user <user>          SSH login username (required)
  -l, --local-port <port>    Local port to listen on (required)
  -t, --remote-host <host>   Target host relative to VPS (default: localhost)
  -r, --remote-port <port>   Target port to forward to (required)
  -i, --key <path>           Path to SSH private key file
  -P, --password <pass>      SSH password (requires sshpass)
      --skip-check           Skip SSH reachability check before starting tunnel
  -n, --non-interactive      Fail instead of prompting for missing options
  -h, --help                 Show this help message and exit

Examples:
  # Interactive mode
  ${0:t}

  # Non-interactive / alias mode
  ${0:t} -H 203.0.113.10 -u ubuntu -l 8080 -r 80
  ${0:t} --host vps.example.com --port 2222 --user deploy --local-port 5432 --remote-host 127.0.0.1 --remote-port 5432 --key ~/.ssh/id_ed25519
EOF
}

# Validate TCP port number (1-65535) using framework validation
validate_port() {
  local val="$1"
  validate_is_number "${val}" || return 1
  if [[ "${val}" == *.* ]] || (( val < 1 || val > 65535 )); then
    return 1
  fi
  return 0
}

# Prompt for input with optional default and validation loop using framework functions
prompt_validated() {
  local prompt="$1"
  local default_val="$2"
  local val_func="$3"
  local err_msg="${4:-Invalid input. Please try again.}"
  local value

  while true; do
    value=$(read_input "${prompt}" "${default_val}")
    if [[ -n "${val_func}" ]]; then
      if "${val_func}" "${value}" &>/dev/null; then
        echo "${value}"
        return 0
      fi
      log_error "${err_msg}"
    else
      echo "${value}"
      return 0
    fi
  done
}

# Initialize parameters
ssh_host=""
ssh_port=""
ssh_user=""
local_port=""
remote_host=""
remote_port=""
key_file=""
password=""
skip_check=0
non_interactive=0

# Parse CLI flags
while (( $# > 0 )); do
  case "$1" in
    -H|--host)
      [[ -n "${2:-}" ]] || error_exit "Option $1 requires an argument" 1
      ssh_host="$2"
      shift 2
      ;;
    -p|--port)
      [[ -n "${2:-}" ]] || error_exit "Option $1 requires an argument" 1
      ssh_port="$2"
      shift 2
      ;;
    -u|--user)
      [[ -n "${2:-}" ]] || error_exit "Option $1 requires an argument" 1
      ssh_user="$2"
      shift 2
      ;;
    -l|--local-port)
      [[ -n "${2:-}" ]] || error_exit "Option $1 requires an argument" 1
      local_port="$2"
      shift 2
      ;;
    -t|--remote-host)
      [[ -n "${2:-}" ]] || error_exit "Option $1 requires an argument" 1
      remote_host="$2"
      shift 2
      ;;
    -r|--remote-port)
      [[ -n "${2:-}" ]] || error_exit "Option $1 requires an argument" 1
      remote_port="$2"
      shift 2
      ;;
    -i|--key)
      [[ -n "${2:-}" ]] || error_exit "Option $1 requires an argument" 1
      key_file="$2"
      shift 2
      ;;
    -P|--password)
      [[ -n "${2:-}" ]] || error_exit "Option $1 requires an argument" 1
      password="$2"
      shift 2
      ;;
    --skip-check)
      skip_check=1
      shift
      ;;
    -n|--non-interactive)
      non_interactive=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      error_exit "Unknown option: $1 (use --help for usage)" 1
      ;;
  esac
done

# Determine if interactive prompting is needed
needs_prompt=0
if [[ -z "${ssh_host}" || -z "${ssh_user}" || -z "${local_port}" || -z "${remote_port}" ]]; then
  needs_prompt=1
fi

if (( non_interactive == 1 )); then
  needs_prompt=0
fi

if (( needs_prompt == 1 )); then
  log_section "SSH Tunnel Interactive Setup"

  if [[ -z "${ssh_host}" ]]; then
    ssh_host=$(prompt_validated "Enter VPS / SSH server host (IP or domain)" "ravinath-prod" "validate_required" "Server host is required.")
  fi

  if [[ -z "${ssh_port}" ]]; then
    ssh_port=$(prompt_validated "Enter SSH server port" "22" "validate_port" "SSH port must be a valid port (1-65535).")
  fi

  if [[ -z "${ssh_user}" ]]; then
    ssh_user=$(prompt_validated "Enter SSH username" "ravi" "validate_required" "SSH username is required.")
  fi

  if [[ -z "${local_port}" ]]; then
    local_port=$(prompt_validated "Enter local port to forward from" "3000" "validate_port" "Local port must be a valid port (1-65535).")
  fi

  if [[ -z "${remote_host}" ]]; then
    remote_host=$(prompt_validated "Enter target host on remote side" "localhost" "validate_required" "Remote target host is required.")
  fi

  if [[ -z "${remote_port}" ]]; then
    remote_port=$(prompt_validated "Enter target port on remote side" "3000" "validate_port" "Remote port must be a valid port (1-65535).")
  fi

  if [[ -z "${key_file}" && -z "${password}" ]]; then
    local auth_method
    auth_method=$(select_option "Select SSH authentication method:" "default-ssh key-file password")
    case "${auth_method}" in
      key-file)
        key_file=$(prompt_validated "Enter path to SSH private key" "${HOME}/.ssh/id_autopilot" "validate_file_exists" "Key file not found. Please enter a valid file path.")
        ;;
      password)
        password=$(read_password "Enter SSH password")
        validate_required "${password}" "Password cannot be empty" || error_exit "Password authentication selected but no password provided" 1
        ;;
      *)
        log_info "Using default SSH agent / ~/.ssh/config keys."
        ;;
    esac
  fi

  log_info "Tunnel Summary: localhost:${local_port} -> ${remote_host}:${remote_port} via ${ssh_user}@${ssh_host}:${ssh_port}"
  if ! confirm "Start SSH tunnel now?" "y"; then
    log_warn "SSH tunnel creation cancelled by user."
    exit 0
  fi
fi

# Apply defaults for optional parameters when running non-interactively
ssh_port="${ssh_port:-22}"
remote_host="${remote_host:-localhost}"

# Validate all parameters using framework functions
log_steps "Validating tunnel parameters"
validate_required "${ssh_host}" "VPS / SSH host is required (-H / --host)" || error_exit "Missing SSH host" 1
validate_required "${ssh_user}" "SSH username is required (-u / --user)" || error_exit "Missing SSH user" 1
validate_required "${local_port}" "Local port is required (-l / --local-port)" || error_exit "Missing local port" 1
validate_required "${remote_host}" "Remote host is required (-t / --remote-host)" || error_exit "Missing remote host" 1
validate_required "${remote_port}" "Remote port is required (-r / --remote-port)" || error_exit "Missing remote port" 1

validate_port "${ssh_port}" || error_exit "Invalid SSH port: ${ssh_port}" 1
validate_port "${local_port}" || error_exit "Invalid local port: ${local_port}" 1
validate_port "${remote_port}" || error_exit "Invalid remote port: ${remote_port}" 1

if [[ -n "${key_file}" ]]; then
  validate_file_exists "${key_file}" || error_exit "SSH key file does not exist: ${key_file}" 1
fi

# Pre-flight reachability check
if (( skip_check == 0 )); then
  log_steps "Checking SSH reachability for ${ssh_host}:${ssh_port}"
  if ! ssh_is_reachable "${ssh_host}" "${ssh_port}" 5; then
    error_exit "SSH server ${ssh_host}:${ssh_port} is unreachable" 1
  fi
fi

# Start the SSH tunnel using the framework function
log_steps "Starting SSH tunnel (localhost:${local_port} -> ${remote_host}:${remote_port} via ${ssh_user}@${ssh_host}:${ssh_port})"
tunnel_pid=$(ssh_tunnel_start "${local_port}" "${remote_host}" "${remote_port}" "${ssh_user}" "${ssh_host}" "${ssh_port}" "${key_file}" "${password}")
tunnel_status=$?

if (( tunnel_status != 0 )) || [[ -z "${tunnel_pid}" ]]; then
  error_exit "Failed to establish SSH tunnel to ${ssh_user}@${ssh_host}:${ssh_port}" 1
fi

log_info "SSH tunnel established successfully (PID: ${tunnel_pid})."
log_info "Forwarding: localhost:${local_port} -> ${remote_host}:${remote_port}"
log_info "To stop the tunnel, run: kill ${tunnel_pid}"

echo "${tunnel_pid}"
exit 0
