# SSH Module Reference

- **Source File:** [`functions/12-ssh.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/12-ssh.sh)
- **Description:** SSH connection, command execution, SCP file copy, and tunnel management utilities supporting key or password authentication.

---

## Detailed Usage Examples

### Integration Setup
Since all modules are loaded dynamically, simply source the configuration script:

```zsh
source ./config/config.sh
init_config
```

---

## Function Signatures & Descriptions

### `ssh_is_reachable`

* **Signature:** `ssh_is_reachable <host> [port] [timeout]`
* **Description:** Verifies if a remote host is accepting connections on the SSH port.

#### Example Code:
```zsh
if ssh_is_reachable "10.0.0.5" 22 2; then
  log_info "Host is reachable via SSH."
else
  log_error "Host is offline or SSH port is closed."
fi
```

---

### `ssh_exec`

* **Signature:** `ssh_exec <user> <host> <command> [port] [key_file] [password]`
* **Description:** Runs a command on a remote server over SSH. Supports private keys or password auth (requires `sshpass`).

#### Example Code:
```zsh
# Using SSH private key identity
local res
res=$(ssh_exec "ubuntu" "10.0.0.5" "df -h" 22 "~/.ssh/id_rsa")
echo "${res}"

# Using Password authentication (sshpass must be installed)
ssh_exec "ubuntu" "10.0.0.5" "sudo systemctl restart nginx" 22 "" "my-secret-pass"
```

---

### `ssh_scp_up`

* **Signature:** `ssh_scp_up <local_path> <remote_path> <user> <host> [port] [key_file] [password]`
* **Description:** Recursively uploads files or folders to a remote location.

#### Example Code:
```zsh
ssh_scp_up "/var/www/dist" "/var/www/html/" "deploy" "10.0.0.10" 22 "~/.ssh/deploy_key"
```

---

### `ssh_scp_down`

* **Signature:** `ssh_scp_down <remote_path> <local_path> <user> <host> [port] [key_file] [password]`
* **Description:** Downloads files or folders from a remote location.

#### Example Code:
```zsh
ssh_scp_down "/var/log/syslog" "/tmp/remote_syslog.log" "admin" "10.0.0.12"
```

---

### `ssh_tunnel_start`

* **Signature:** `ssh_tunnel_start <local_port> <remote_host> <remote_port> <user> <host> [port] [key_file] [password]`
* **Description:** Starts a local port forwarding SSH tunnel running in the background. Returns the PID of the background tunnel process.

#### Example Code:
```zsh
# Forwards local port 8080 to remote port 80 on the target db-host relative to the gateway 10.0.0.5
local tunnel_pid
tunnel_pid=$(ssh_tunnel_start 8080 "db-host" 80 "gateway-user" "10.0.0.5")

# Close tunnel later
kill "${tunnel_pid}"
```
