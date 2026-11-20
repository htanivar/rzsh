# `init_evidence`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../99-evidences.md) › [Function Index](README.md) › **`init_evidence`** › [Runnable Example](../../examples/99_evidences_example.sh) › [Tests](../../tests/99-evidences.test.sh)

- **Source:** [`functions/99-evidences.sh#L25-L41`](../../functions/99-evidences.sh#L25-L41)
- **Signature:** `init_evidence`
- **Description:** Initializes an evidence collection session, creating a timestamped folder inside EVIDENCE_DIR.

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

- {number} 0 on success, or non-zero on failure.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  init_evidence
```

---

See also the full runnable example script: [`examples/99_evidences_example.sh`](../../examples/99_evidences_example.sh).
