# `mock_uuid`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../17-mock.md) › [Function Index](README.md) › **`mock_uuid`** › [Runnable Example](../../examples/17_mock_example.sh) › [Tests](../../tests/17-mock.test.sh)

- **Source:** [`functions/17-mock.sh#L215-L224`](../../functions/17-mock.sh#L215-L224)
- **Signature:** `mock_uuid`
- **Description:** Generates a random RFC 4122 version 4 UUID.

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

- {string} UUID v4 string.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  uid=$(mock_uuid)
```

---

See also the full runnable example script: [`examples/17_mock_example.sh`](../../examples/17_mock_example.sh).
