# `evidence_validate`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../99-evidences.md) › [Function Index](README.md) › **`evidence_validate`** › [Runnable Example](../../examples/99_evidences_example.sh) › [Tests](../../tests/99-evidences.test.sh)

- **Source:** [`functions/99-evidences.sh#L429-L435`](../../functions/99-evidences.sh#L429-L435)
- **Signature:** `evidence_validate <data>`
- **Description:** Validates if a consolidated evidence JSON payload conforms to structural requirements.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `data` (`string`) | JSON string to validate. |

## Return / Exit Value

- {number} 0 if valid, 1 otherwise.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  if evidence_validate "${payload}"; then
    echo "Conforms to schema"
  fi
```

---

See also the full runnable example script: [`examples/99_evidences_example.sh`](../../examples/99_evidences_example.sh).
