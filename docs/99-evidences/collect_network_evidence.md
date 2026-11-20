# `collect_network_evidence`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../99-evidences.md) › [Function Index](README.md) › **`collect_network_evidence`** › [Runnable Example](../../examples/99_evidences_example.sh) › [Tests](../../tests/99-evidences.test.sh)

- **Source:** [`functions/99-evidences.sh#L120-L144`](../../functions/99-evidences.sh#L120-L144)
- **Signature:** `collect_network_evidence`
- **Description:** Collects network configuration details, DNS servers, and basic external connectivity status.

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

- {number} 0 on success.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  collect_network_evidence
```

---

See also the full runnable example script: [`examples/99_evidences_example.sh`](../../examples/99_evidences_example.sh).
