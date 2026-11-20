# SSH & SCP Client — Function Index

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../12-ssh.md) › **12-ssh/** › [Runnable Example](../../examples/12_ssh_example.sh) › [Tests](../../tests/12-ssh.test.sh)

- **Source File:** [`functions/12-ssh.sh`](../../functions/12-ssh.sh)
- **Runnable Example:** [`examples/12_ssh_example.sh`](../../examples/12_ssh_example.sh)

| Function | Signature | Description |
| :--- | :--- | :--- |
| [`ssh_is_reachable`](ssh_is_reachable.md) | `ssh_is_reachable <host> [port=22] [timeout=2]` | Checks if the SSH service on a remote host is reachable and accepting connections. |
| [`ssh_exec`](ssh_exec.md) | `ssh_exec <user> <host> <cmd> [port=22] [key_file] [password]` | Executes a command on a remote host via SSH, supporting optional identity keys or password auth. |
| [`ssh_scp_up`](ssh_scp_up.md) | `ssh_scp_up <local_path> <remote_path> <user> <host> [port=22] [key_file] [password]` | Copies local files or directories to a remote host over SCP. |
| [`ssh_scp_down`](ssh_scp_down.md) | `ssh_scp_down <remote_path> <local_path> <user> <host> [port=22] [key_file] [password]` | Downloads files or directories from a remote host to local system. |
| [`ssh_tunnel_start`](ssh_tunnel_start.md) | `ssh_tunnel_start <local_port> <remote_host> <remote_port> <user> <host> [port=22] [key_file] [password]` | Establishes a local port forwarding SSH tunnel running in the background. |
