# `ssh_scp_up`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../12-ssh.md) › [Function Index](README.md) › **`ssh_scp_up`** › [Runnable Example](../../examples/12_ssh_example.sh) › [Tests](../../tests/12-ssh.test.sh)

- **Source:** [`functions/12-ssh.sh#L145-L181`](../../functions/12-ssh.sh#L145-L181)
- **Signature:** `ssh_scp_up <local_path> <remote_path> <user> <host> [port=22] [key_file] [password]`
- **Description:** Copies local files or directories to a remote host over SCP.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `local_path` (`string`) | Local file or folder path. |
| `remote_path` (`string`) | Target path on remote host. |
| `user` (`string`) | SSH user. |
| `host` (`string`) | SSH host. |
| `[port=22]` (`number`) | SSH port. |
| `[key_file]` (`string`) | Path to private key file. |
| `[password]` (`string`) | SSH password (requires sshpass). |

## Return / Exit Value

- {number} 0 on success, non-zero on failure.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  ssh_scp_up "/tmp/backup.tar" "/home/ubuntu/" "ubuntu" "10.0.0.5"
```

---

See also the full runnable example script: [`examples/12_ssh_example.sh`](../../examples/12_ssh_example.sh).
