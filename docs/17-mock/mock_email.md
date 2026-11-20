# `mock_email`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../17-mock.md) › [Function Index](README.md) › **`mock_email`** › [Runnable Example](../../examples/17_mock_example.sh) › [Tests](../../tests/17-mock.test.sh)

- **Source:** [`functions/17-mock.sh#L234-L239`](../../functions/17-mock.sh#L234-L239)
- **Signature:** `mock_email [domain="example.com"]`
- **Description:** Generates a random dummy email address.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `[domain="example.com"]` (`string`) | Email domain name. |

## Return / Exit Value

- {string} Dummy email address.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  email=$(mock_email "acme.test")
```

---

See also the full runnable example script: [`examples/17_mock_example.sh`](../../examples/17_mock_example.sh).
