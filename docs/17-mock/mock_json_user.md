# `mock_json_user`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../17-mock.md) › [Function Index](README.md) › **`mock_json_user`** › [Runnable Example](../../examples/17_mock_example.sh) › [Tests](../../tests/17-mock.test.sh)

- **Source:** [`functions/17-mock.sh#L423-L434`](../../functions/17-mock.sh#L423-L434)
- **Signature:** `mock_json_user`
- **Description:** Generates a realistic dummy user JSON payload including nested metadata, roles array, and tokens.

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

- {string} Valid JSON user object string.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  user_json=$(mock_json_user)
```

---

See also the full runnable example script: [`examples/17_mock_example.sh`](../../examples/17_mock_example.sh).
