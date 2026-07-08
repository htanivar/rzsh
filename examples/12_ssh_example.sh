#!/usr/bin/env zsh
# examples/12_ssh_example.sh
# Non-technical guide to running SSH remote commands, SCP file transfers, and SSH tunnels.

source "$(dirname "$0")/../config/config.sh"
init_config

echo "=== SSH and Network utilities Demo ==="

# 1. Check if SSH port (22) is open on a host
echo "Checking if google.com SSH port is open..."
if ssh_is_reachable "google.com" 22 2; then
  echo "SSH is reachable."
else
  echo "SSH port is not responding (expected for google.com)."
fi

# 2. Remote Command Execution example (mocked usage description)
echo ""
echo "Example of executing a remote command over SSH with identity key:"
echo '  ssh_exec "ubuntu" "10.0.0.5" "df -h" 22 "~/.ssh/id_rsa"'

# 3. SCP file upload example (mocked usage description)
echo ""
echo "Example of uploading a local folder to a remote server:"
echo '  ssh_scp_up "/local/workspace" "/var/www/html/" "deployer" "10.0.0.10"'

# 4. SSH Local Port Forwarding Tunnel example (mocked usage description)
echo ""
echo "Example of starting an SSH tunnel in the background:"
echo '  local tunnel_pid'
echo '  tunnel_pid=$(ssh_tunnel_start 8080 "mysql-db-server" 3306 "bastion-user" "jump.server.com")'
echo '  echo "Tunnel PID is: ${tunnel_pid}"'
echo '  kill "${tunnel_pid}"'
