# functions/12-ssh.sh

# Protect against double sourcing
if [[ -n "${_SSH_SH_SOURCED:-}" ]]; then
  return 0
fi
readonly _SSH_SH_SOURCED=1

# Ensure config is sourced if available
if [[ -f "${PROJECT_ROOT:-.}/config/config.sh" ]]; then
  source "${PROJECT_ROOT:-.}/config/config.sh"
fi

# /**
#  * @function ssh_is_reachable
#  * @description Checks if the SSH service on a remote host is reachable and accepting connections.
#  * @param {string} host - Remote host IP or domain.
#  * @param {number} [port=22] - SSH port.
#  * @param {number} [timeout=2] - Connection timeout in seconds.
#  * @return {number} 0 if reachable, 1 otherwise.
#  * @example
#  *   if ssh_is_reachable "192.168.1.50" 22; then
#  *     echo "SSH is up"
#  *   fi
#  */
ssh_is_reachable() {
  local host="$1"
  local port="${2:-22}"
  local timeout="${3:-2}"
  
  if [[ -z "${host}" ]]; then
    return 1
  fi
  
  # Try native Zsh ztcp if available
  zmodload zsh/net/tcp 2>/dev/null
  if whence ztcp &>/dev/null; then
    # ztcp doesn't have an inline timeout, so we run in subshell with timeout
    if command -v timeout &>/dev/null; then
      timeout "${timeout}" zsh -c "zmodload zsh/net/tcp && ztcp '${host}' '${port}'" &>/dev/null
      return $?
    else
      ztcp "${host}" "${port}" &>/dev/null
      return $?
    fi
  fi
  
  # Fallback to nc (netcat)
  if command -v nc &>/dev/null; then
    nc -z -w "${timeout}" "${host}" "${port}" &>/dev/null
    return $?
  fi
  
  # Fallback to bash/zsh /dev/tcp if enabled
  (exec 3<>/dev/tcp/"${host}"/"${port}") &>/dev/null
  return $?
}

# Helper to build SSH/SCP options
_build_ssh_opts() {
  local port="$1"
  local key_file="$2"
  local -a opts
  opts=(
    -o "StrictHostKeyChecking=no"
    -o "UserKnownHostsFile=/dev/null"
    -o "ConnectTimeout=5"
  )
  if [[ -n "${port}" ]]; then
    opts+=( -p "${port}" )
  fi
  if [[ -n "${key_file}" && -f "${key_file}" ]]; then
    opts+=( -i "${key_file}" )
  fi
  echo "${opts[@]}"
}

# /**
#  * @function ssh_exec
#  * @description Executes a command on a remote host via SSH, supporting optional identity keys or password auth.
#  * @param {string} user - SSH user.
#  * @param {string} host - SSH host.
#  * @param {string} cmd - Command to execute.
#  * @param {number} [port=22] - SSH port.
#  * @param {string} [key_file] - Path to private key file.
#  * @param {string} [password] - SSH password (requires sshpass).
#  * @return {number} Exit code of remote execution, or 127/1 on failure.
#  * @example
#  *   ssh_exec "ubuntu" "10.0.0.5" "uname -a" 22 "/home/user/.ssh/id_rsa"
#  */
ssh_exec() {
  local user="$1"
  local host="$2"
  local cmd="$3"
  local port="${4:-22}"
  local key_file="${5:-}"
  local password="${6:-}"
  
  if [[ -z "${user}" || -z "${host}" || -z "${cmd}" ]]; then
    return 1
  fi
  
  local -a ssh_cmd
  ssh_cmd=( ssh )
  
  # StrictHostKeyChecking=no prevents prompt, ConnectTimeout limits wait
  ssh_cmd+=( -o "StrictHostKeyChecking=no" )
  ssh_cmd+=( -o "UserKnownHostsFile=/dev/null" )
  ssh_cmd+=( -o "ConnectTimeout=5" )
  ssh_cmd+=( -p "${port}" )
  
  if [[ -n "${key_file}" ]]; then
    ssh_cmd+=( -i "${key_file}" )
  fi
  
  ssh_cmd+=( "${user}@${host}" "${cmd}" )
  
  if [[ -n "${password}" ]]; then
    if ! command -v sshpass &>/dev/null; then
      printf 'Error: password authentication requested but sshpass is not installed.\n' >&2
      return 127
    fi
    sshpass -p "${password}" "${ssh_cmd[@]}"
    return $?
  else
    "${ssh_cmd[@]}"
    return $?
  fi
}

# /**
#  * @function ssh_scp_up
#  * @description Copies local files or directories to a remote host over SCP.
#  * @param {string} local_path - Local file or folder path.
#  * @param {string} remote_path - Target path on remote host.
#  * @param {string} user - SSH user.
#  * @param {string} host - SSH host.
#  * @param {number} [port=22] - SSH port.
#  * @param {string} [key_file] - Path to private key file.
#  * @param {string} [password] - SSH password (requires sshpass).
#  * @return {number} 0 on success, non-zero on failure.
#  * @example
#  *   ssh_scp_up "/tmp/backup.tar" "/home/ubuntu/" "ubuntu" "10.0.0.5"
#  */
ssh_scp_up() {
  local local_path="$1"
  local remote_path="$2"
  local user="$3"
  local host="$4"
  local port="${5:-22}"
  local key_file="${6:-}"
  local password="${7:-}"
  
  if [[ -z "${local_path}" || -z "${remote_path}" || -z "${user}" || -z "${host}" ]]; then
    return 1
  fi
  
  local -a scp_cmd
  scp_cmd=( scp -r )
  scp_cmd+=( -P "${port}" )
  scp_cmd+=( -o "StrictHostKeyChecking=no" )
  scp_cmd+=( -o "UserKnownHostsFile=/dev/null" )
  
  if [[ -n "${key_file}" ]]; then
    scp_cmd+=( -i "${key_file}" )
  fi
  
  scp_cmd+=( "${local_path}" "${user}@${host}:${remote_path}" )
  
  if [[ -n "${password}" ]]; then
    if ! command -v sshpass &>/dev/null; then
      printf 'Error: password authentication requested but sshpass is not installed.\n' >&2
      return 127
    fi
    sshpass -p "${password}" "${scp_cmd[@]}"
    return $?
  else
    "${scp_cmd[@]}"
    return $?
  fi
}

# /**
#  * @function ssh_scp_down
#  * @description Downloads files or directories from a remote host to local system.
#  * @param {string} remote_path - Remote file or folder path.
#  * @param {string} local_path - Local target path.
#  * @param {string} user - SSH user.
#  * @param {string} host - SSH host.
#  * @param {number} [port=22] - SSH port.
#  * @param {string} [key_file] - Path to private key.
#  * @param {string} [password] - SSH password.
#  * @return {number} 0 on success.
#  * @example
#  *   ssh_scp_down "/var/log/nginx/access.log" "/tmp/remote_access.log" "ubuntu" "10.0.0.5"
#  */
ssh_scp_down() {
  local remote_path="$1"
  local local_path="$2"
  local user="$3"
  local host="$4"
  local port="${5:-22}"
  local key_file="${6:-}"
  local password="${7:-}"
  
  if [[ -z "${remote_path}" || -z "${local_path}" || -z "${user}" || -z "${host}" ]]; then
    return 1
  fi
  
  local -a scp_cmd
  scp_cmd=( scp -r )
  scp_cmd+=( -P "${port}" )
  scp_cmd+=( -o "StrictHostKeyChecking=no" )
  scp_cmd+=( -o "UserKnownHostsFile=/dev/null" )
  
  if [[ -n "${key_file}" ]]; then
    scp_cmd+=( -i "${key_file}" )
  fi
  
  scp_cmd+=( "${user}@${host}:${remote_path}" "${local_path}" )
  
  if [[ -n "${password}" ]]; then
    if ! command -v sshpass &>/dev/null; then
      printf 'Error: password authentication requested but sshpass is not installed.\n' >&2
      return 127
    fi
    sshpass -p "${password}" "${scp_cmd[@]}"
    return $?
  else
    "${scp_cmd[@]}"
    return $?
  fi
}

# /**
#  * @function ssh_tunnel_start
#  * @description Establishes a local port forwarding SSH tunnel running in the background.
#  * @param {number} local_port - Local port to listen on.
#  * @param {string} remote_host - Target host to forward to (relative to SSH host).
#  * @param {number} remote_port - Target port to forward to.
#  * @param {string} user - SSH login user.
#  * @param {string} host - SSH tunnel server host.
#  * @param {number} [port=22] - SSH server port.
#  * @param {string} [key_file] - Private key path.
#  * @param {string} [password] - SSH password.
#  * @return {number} Prints background tunnel SSH process PID on success, returns 1 on failure.
#  * @example
#  *   local pid
#  *   pid=$(ssh_tunnel_start 8080 "localhost" 80 "ubuntu" "10.0.0.5")
#  */
ssh_tunnel_start() {
  local local_port="$1"
  local remote_host="$2"
  local remote_port="$3"
  local user="$4"
  local host="$5"
  local port="${6:-22}"
  local key_file="${7:-}"
  local password="${8:-}"
  
  if [[ -z "${local_port}" || -z "${remote_host}" || -z "${remote_port}" || -z "${user}" || -z "${host}" ]]; then
    return 1
  fi
  
  local -a ssh_cmd
  ssh_cmd=( ssh -N -L "${local_port}:${remote_host}:${remote_port}" )
  ssh_cmd+=( -o "StrictHostKeyChecking=no" )
  ssh_cmd+=( -o "UserKnownHostsFile=/dev/null" )
  ssh_cmd+=( -p "${port}" )
  
  if [[ -n "${key_file}" ]]; then
    ssh_cmd+=( -i "${key_file}" )
  fi
  ssh_cmd+=( "${user}@${host}" )
  
  local pid
  if [[ -n "${password}" ]]; then
    if ! command -v sshpass &>/dev/null; then
      printf 'Error: password authentication requested but sshpass is not installed.\n' >&2
      return 127
    fi
    sshpass -p "${password}" "${ssh_cmd[@]}" &
    pid=$!
  else
    "${ssh_cmd[@]}" &
    pid=$!
  fi
  
  # Verify background process is still running after a split second
  sleep 0.5
  if kill -0 "${pid}" 2>/dev/null; then
    echo "${pid}"
    return 0
  else
    return 1
  fi
}
