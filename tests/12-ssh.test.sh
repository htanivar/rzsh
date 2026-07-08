# tests/12-ssh.test.sh

# Source helpers, config, and target script
local my_dir="${${(%):-%x}:A:h}"
source "${my_dir}/test_helpers.sh"
source "${my_dir}/../config/config.sh"
source "${my_dir}/../functions/12-ssh.sh"

init_config

# Files for persistent mock verification across subshells
local ssh_args_file="${PROJECT_ROOT}/logs/mock_ssh_args.txt"
local scp_args_file="${PROJECT_ROOT}/logs/mock_scp_args.txt"
local sshpass_args_file="${PROJECT_ROOT}/logs/mock_sshpass_args.txt"
local MOCK_SSHPASS_EXISTS=1

# Clean up mock files before testing
rm -f "${ssh_args_file}" "${scp_args_file}" "${sshpass_args_file}"

# Mock binaries
ssh() {
  echo "$@" > "${ssh_args_file}"
  echo "mock_ssh_output"
  if [[ "$*" == *"-N"* ]]; then
    sleep 2
  fi
  return 0
}

scp() {
  echo "$@" > "${scp_args_file}"
  echo "mock_scp_output"
  return 0
}

sshpass() {
  echo "$@" > "${sshpass_args_file}"
  # Execute the remaining args as the command to mock sshpass execution
  shift 2 # remove "-p" and "password"
  "$@"
  return $?
}

# Override command -v for sshpass checking
command() {
  if [[ "$1" == "-v" && "$2" == "sshpass" ]]; then
    if (( MOCK_SSHPASS_EXISTS == 1 )); then
      echo "/usr/bin/sshpass"
      return 0
    else
      return 1
    fi
  fi
  builtin command "$@"
}

test_ssh_is_reachable_fail() {
  ssh_is_reachable "127.0.0.1" 59999 1
  assert_equals 1 $? "Port 59999 on localhost should be unreachable"
}

test_ssh_exec_key() {
  rm -f "${ssh_args_file}" "${sshpass_args_file}"
  
  ssh_exec "testuser" "10.0.0.5" "ls -la" 2222 "/tmp/dummy_key"
  assert_equals 0 $? "ssh_exec with key should succeed"
  
  local args
  args=$(cat "${ssh_args_file}" 2>/dev/null)
  
  assert_true "[[ \"${args}\" == *\"-p 2222\"* ]]" "Should include port 2222"
  assert_true "[[ \"${args}\" == *\"-i /tmp/dummy_key\"* ]]" "Should include identity file path"
  assert_true "[[ \"${args}\" == *\"testuser@10.0.0.5\"* ]]" "Should target correct destination"
  assert_true "[[ \"${args}\" == *\"ls -la\"* ]]" "Should pass command string"
}

test_ssh_exec_password() {
  rm -f "${ssh_args_file}" "${sshpass_args_file}"
  MOCK_SSHPASS_EXISTS=1
  
  ssh_exec "testuser" "10.0.0.5" "whoami" 22 "" "secretpass"
  assert_equals 0 $? "ssh_exec with password should succeed"
  
  local pass_args
  pass_args=$(cat "${sshpass_args_file}" 2>/dev/null)
  assert_true "[[ \"${pass_args}\" == *\"whoami\"* ]]" "sshpass should execute ssh command"
}

test_ssh_scp_up() {
  rm -f "${scp_args_file}"
  ssh_scp_up "/local/file.txt" "/remote/dir" "testuser" "10.0.0.5" 22 "/tmp/dummy_key"
  assert_equals 0 $? "ssh_scp_up should succeed"
  
  local args
  args=$(cat "${scp_args_file}" 2>/dev/null)
  
  assert_true "[[ \"${args}\" == *\"-P 22\"* ]]" "Should specify SCP port"
  assert_true "[[ \"${args}\" == *\"-i /tmp/dummy_key\"* ]]" "Should include identity key file"
  assert_true "[[ \"${args}\" == *\"/local/file.txt testuser@10.0.0.5:/remote/dir\"* ]]" "Should specify correct copy arguments"
}

test_ssh_scp_down() {
  rm -f "${scp_args_file}"
  ssh_scp_down "/remote/file.txt" "/local/dir" "testuser" "10.0.0.5" 22 "/tmp/dummy_key"
  assert_equals 0 $? "ssh_scp_down should succeed"
  
  local args
  args=$(cat "${scp_args_file}" 2>/dev/null)
  assert_true "[[ \"${args}\" == *\"testuser@10.0.0.5:/remote/file.txt /local/dir\"* ]]" "Should specify correct scp download paths"
}

test_ssh_tunnel() {
  rm -f "${ssh_args_file}"
  local pid
  pid=$(ssh_tunnel_start 8080 "localhost" 80 "testuser" "10.0.0.5" 22 "/tmp/dummy_key")
  assert_equals 0 $? "ssh_tunnel_start should succeed"
  assert_true "[[ -n \"${pid}\" ]]" "Should return background process PID"
  
  local args
  args=$(cat "${ssh_args_file}" 2>/dev/null)
  assert_true "[[ \"${args}\" == *\"-N -L 8080:localhost:80\"* ]]" "Should build local port forwarding options"
  
  # Clean up background process
  kill "${pid}" &>/dev/null
  rm -f "${ssh_args_file}" "${scp_args_file}" "${sshpass_args_file}"
}

run_test test_ssh_is_reachable_fail
run_test test_ssh_exec_key
run_test test_ssh_exec_password
run_test test_ssh_scp_up
run_test test_ssh_scp_down
run_test test_ssh_tunnel

# Final cleanup of files
rm -f "${ssh_args_file}" "${scp_args_file}" "${sshpass_args_file}"

exit $(( TESTS_FAILED > 0 ? 1 : 0 ))
