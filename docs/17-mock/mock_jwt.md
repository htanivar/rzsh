# `mock_jwt`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../17-mock.md) › [Function Index](README.md) › **`mock_jwt`** › [Runnable Example](../../examples/17_mock_example.sh) › [Tests](../../tests/17-mock.test.sh)

- **Source:** [`functions/17-mock.sh#L278-L295`](../../functions/17-mock.sh#L278-L295)
- **Signature:** `mock_jwt [sub="mock-user"] [role="admin"]`
- **Description:** Generates a dummy 3-segment JWT token (header.payload.signature). Uses jwt_create if available, otherwise builds a valid base64url JWT.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `[sub="mock-user"]` (`string`) | Subject claim ('sub'). |
| `[role="admin"]` (`string`) | Role claim ('role'). |

## Return / Exit Value

- {string} Dummy JWT string.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  token=$(mock_jwt "alice" "developer")
```

---

See also the full runnable example script: [`examples/17_mock_example.sh`](../../examples/17_mock_example.sh).
