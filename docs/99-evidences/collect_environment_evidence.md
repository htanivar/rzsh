# `collect_environment_evidence`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../99-evidences.md) › [Function Index](README.md) › **`collect_environment_evidence`** › [Runnable Example](../../examples/99_evidences_example.sh) › [Tests](../../tests/99-evidences.test.sh)

- **Source:** [`functions/99-evidences.sh#L64-L82`](../../functions/99-evidences.sh#L64-L82)
- **Signature:** `collect_environment_evidence`
- **Description:** Collects operating system, kernel, arch, env vars, user, and running process info.

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
  collect_environment_evidence
```

---

See also the full runnable example script: [`examples/99_evidences_example.sh`](../../examples/99_evidences_example.sh).
