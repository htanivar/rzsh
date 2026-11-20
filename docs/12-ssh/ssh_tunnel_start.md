# `ssh_tunnel_start`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../12-ssh.md) › [Function Index](README.md) › **`ssh_tunnel_start`** › [Runnable Example](../../examples/12_ssh_example.sh) › [Tests](../../tests/12-ssh.test.sh)

- **Source:** [`functions/12-ssh.sh#L251-L297`](../../functions/12-ssh.sh#L251-L297)
- **Signature:** `ssh_tunnel_start <local_port> <remote_host> <remote_port> <user> <host> [port=22] [key_file] [password]`
- **Description:** Establishes a local port forwarding SSH tunnel running in the background.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `local_port` (`number`) | Local port to listen on. |
| `remote_host` (`string`) | Target host to forward to (relative to SSH host). |
| `remote_port` (`number`) | Target port to forward to. |
| `user` (`string`) | SSH login user. |
| `host` (`string`) | SSH tunnel server host. |
| `[port=22]` (`number`) | SSH server port. |
| `[key_file]` (`string`) | Private key path. |
| `[password]` (`string`) | SSH password. |

## Return / Exit Value

- {number} Prints background tunnel SSH process PID on success, returns 1 on failure.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local pid
  pid=$(ssh_tunnel_start 8080 "localhost" 80 "ubuntu" "10.0.0.5")
```

---

See also the full runnable example script: [`examples/12_ssh_example.sh`](../../examples/12_ssh_example.sh).
