# `mock_phone`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../17-mock.md) › [Function Index](README.md) › **`mock_phone`** › [Runnable Example](../../examples/17_mock_example.sh) › [Tests](../../tests/17-mock.test.sh)

- **Source:** [`functions/17-mock.sh#L249-L254`](../../functions/17-mock.sh#L249-L254)
- **Signature:** `mock_phone`
- **Description:** Generates a random US-style dummy phone number (+1-555-XXX-XXXX).

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

- {string} Dummy phone number.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  phone=$(mock_phone)
```

---

See also the full runnable example script: [`examples/17_mock_example.sh`](../../examples/17_mock_example.sh).
