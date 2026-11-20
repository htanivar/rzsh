# `ssh_exec`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../12-ssh.md) › [Function Index](README.md) › **`ssh_exec`** › [Runnable Example](../../examples/12_ssh_example.sh) › [Tests](../../tests/12-ssh.test.sh)

- **Source:** [`functions/12-ssh.sh#L91-L129`](../../functions/12-ssh.sh#L91-L129)
- **Signature:** `ssh_exec <user> <host> <cmd> [port=22] [key_file] [password]`
- **Description:** Executes a command on a remote host via SSH, supporting optional identity keys or password auth.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `user` (`string`) | SSH user. |
| `host` (`string`) | SSH host. |
| `cmd` (`string`) | Command to execute. |
| `[port=22]` (`number`) | SSH port. |
| `[key_file]` (`string`) | Path to private key file. |
| `[password]` (`string`) | SSH password (requires sshpass). |

## Return / Exit Value

- {number} Exit code of remote execution, or 127/1 on failure.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  ssh_exec "ubuntu" "10.0.0.5" "uname -a" 22 "/home/user/.ssh/id_rsa"
```

---

See also the full runnable example script: [`examples/12_ssh_example.sh`](../../examples/12_ssh_example.sh).
