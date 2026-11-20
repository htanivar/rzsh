# `file_hash`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../09-file.md) › [Function Index](README.md) › **`file_hash`** › [Runnable Example](../../examples/09_file_example.sh) › [Tests](../../tests/09-file.test.sh)

- **Source:** [`functions/09-file.sh#L355-L369`](../../functions/09-file.sh#L355-L369)
- **Signature:** `file_hash <file> [algorithm=sha256]`
- **Description:** Calculates the cryptographic hash of a file.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `file` (`string`) | File path. |
| `[algorithm=sha256]` (`string`) | Hash algorithm (md5, sha1, sha256). |

## Return / Exit Value

- {string} The hash value hex digest.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local hash
  hash=$(file_hash "file.iso" "sha256")
```

### 2. Default SHA-256 and explicit algorithms

```zsh
file_hash "package.tar.gz"
file_hash "package.tar.gz" "sha256"
file_hash "package.tar.gz" "md5"
file_hash "package.tar.gz" "sha1"
```

---

See also the full runnable example script: [`examples/09_file_example.sh`](../../examples/09_file_example.sh).
