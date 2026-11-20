# `evidence_archive`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../99-evidences.md) › [Function Index](README.md) › **`evidence_archive`** › [Runnable Example](../../examples/99_evidences_example.sh) › [Tests](../../tests/99-evidences.test.sh)

- **Source:** [`functions/99-evidences.sh#L387-L402`](../../functions/99-evidences.sh#L387-L402)
- **Signature:** `evidence_archive`
- **Description:** Archives the evidence directory into a tarball.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| — | None |

## Return / Exit Value

- {string} The path to the created tarball.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local archive_file
  archive_file=$(evidence_archive)
```

---

See also the full runnable example script: [`examples/99_evidences_example.sh`](../../examples/99_evidences_example.sh).
