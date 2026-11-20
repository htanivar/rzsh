# `evidence_compare`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../99-evidences.md) › [Function Index](README.md) › **`evidence_compare`** › [Runnable Example](../../examples/99_evidences_example.sh) › [Tests](../../tests/99-evidences.test.sh)

- **Source:** [`functions/99-evidences.sh#L413-L417`](../../functions/99-evidences.sh#L413-L417)
- **Signature:** `evidence_compare <evidence1> <evidence2>`
- **Description:** Compares two consolidated JSON evidence payloads and returns the JSON diff.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `evidence1` (`string`) | Consolidated JSON payload 1. |
| `evidence2` (`string`) | Consolidated JSON payload 2. |

## Return / Exit Value

- {string} Diff output.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  evidence_compare "${data1}" "${data2}"
```

---

See also the full runnable example script: [`examples/99_evidences_example.sh`](../../examples/99_evidences_example.sh).
