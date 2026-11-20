# `ssh_scp_down`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../12-ssh.md) › [Function Index](README.md) › **`ssh_scp_down`** › [Runnable Example](../../examples/12_ssh_example.sh) › [Tests](../../tests/12-ssh.test.sh)

- **Source:** [`functions/12-ssh.sh#L197-L233`](../../functions/12-ssh.sh#L197-L233)
- **Signature:** `ssh_scp_down <remote_path> <local_path> <user> <host> [port=22] [key_file] [password]`
- **Description:** Downloads files or directories from a remote host to local system.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `remote_path` (`string`) | Remote file or folder path. |
| `local_path` (`string`) | Local target path. |
| `user` (`string`) | SSH user. |
| `host` (`string`) | SSH host. |
| `[port=22]` (`number`) | SSH port. |
| `[key_file]` (`string`) | Path to private key. |
| `[password]` (`string`) | SSH password. |

## Return / Exit Value

- {number} 0 on success.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  ssh_scp_down "/var/log/nginx/access.log" "/tmp/remote_access.log" "ubuntu" "10.0.0.5"
```

---

See also the full runnable example script: [`examples/12_ssh_example.sh`](../../examples/12_ssh_example.sh).
