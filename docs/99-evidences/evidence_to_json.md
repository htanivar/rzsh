# `evidence_to_json`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../99-evidences.md) › [Function Index](README.md) › **`evidence_to_json`** › [Runnable Example](../../examples/99_evidences_example.sh) › [Tests](../../tests/99-evidences.test.sh)

- **Source:** [`functions/99-evidences.sh#L287-L312`](../../functions/99-evidences.sh#L287-L312)
- **Signature:** `evidence_to_json`
- **Description:** Consolidates all collected evidence JSON files in the current session into one unified JSON object.

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

- {string} Consolidated JSON string.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local all_data
  all_data=$(evidence_to_json)
```

---

See also the full runnable example script: [`examples/99_evidences_example.sh`](../../examples/99_evidences_example.sh).
