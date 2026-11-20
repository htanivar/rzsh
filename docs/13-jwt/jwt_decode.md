# `jwt_decode`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../13-jwt.md) › [Function Index](README.md) › **`jwt_decode`** › [Runnable Example](../../examples/13_jwt_example.sh) › [Tests](../../tests/13-jwt.test.sh)

- **Source:** [`functions/13-jwt.sh#L88-L102`](../../functions/13-jwt.sh#L88-L102)
- **Signature:** `jwt_decode <token>`
- **Description:** Decodes a JWT token without verifying its signature.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `token` (`string`) | The JWT token. |

## Return / Exit Value

- {string} JSON object containing "header" and "payload".

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  jwt_decode "header.payload.signature"
```

---

See also the full runnable example script: [`examples/13_jwt_example.sh`](../../examples/13_jwt_example.sh).
