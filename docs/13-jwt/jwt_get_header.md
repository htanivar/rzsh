# `jwt_get_header`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../13-jwt.md) › [Function Index](README.md) › **`jwt_get_header`** › [Runnable Example](../../examples/13_jwt_example.sh) › [Tests](../../tests/13-jwt.test.sh)

- **Source:** [`functions/13-jwt.sh#L112-L120`](../../functions/13-jwt.sh#L112-L120)
- **Signature:** `jwt_get_header <token>`
- **Description:** Extracts and decodes the header part of a JWT.

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

- {string} JSON header object.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  jwt_get_header "header.payload.signature"
```

---

See also the full runnable example script: [`examples/13_jwt_example.sh`](../../examples/13_jwt_example.sh).
