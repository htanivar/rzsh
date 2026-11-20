# `ssh_is_reachable`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../12-ssh.md) › [Function Index](README.md) › **`ssh_is_reachable`** › [Runnable Example](../../examples/12_ssh_example.sh) › [Tests](../../tests/12-ssh.test.sh)

- **Source:** [`functions/12-ssh.sh#L26-L57`](../../functions/12-ssh.sh#L26-L57)
- **Signature:** `ssh_is_reachable <host> [port=22] [timeout=2]`
- **Description:** Checks if the SSH service on a remote host is reachable and accepting connections.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `host` (`string`) | Remote host IP or domain. |
| `[port=22]` (`number`) | SSH port. |
| `[timeout=2]` (`number`) | Connection timeout in seconds. |

## Return / Exit Value

- {number} 0 if reachable, 1 otherwise.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  if ssh_is_reachable "192.168.1.50" 22; then
    echo "SSH is up"
  fi
```

---

See also the full runnable example script: [`examples/12_ssh_example.sh`](../../examples/12_ssh_example.sh).
