# `collect_file_evidence`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../99-evidences.md) › [Function Index](README.md) › **`collect_file_evidence`** › [Runnable Example](../../examples/99_evidences_example.sh) › [Tests](../../tests/99-evidences.test.sh)

- **Source:** [`functions/99-evidences.sh#L154-L187`](../../functions/99-evidences.sh#L154-L187)
- **Signature:** `collect_file_evidence <files>`
- **Description:** Collects size, checksums, metadata, and head contents for specified target files.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `files` (`string`) | Space-separated list of file paths. |

## Return / Exit Value

- {number} 0 on success.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  collect_file_evidence "/etc/hosts /etc/resolv.conf"
```

---

See also the full runnable example script: [`examples/99_evidences_example.sh`](../../examples/99_evidences_example.sh).
