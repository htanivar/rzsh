# `jwt_parse_claims`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../13-jwt.md) › [Function Index](README.md) › **`jwt_parse_claims`** › [Runnable Example](../../examples/13_jwt_example.sh) › [Tests](../../tests/13-jwt.test.sh)

- **Source:** [`functions/13-jwt.sh#L281-L283`](../../functions/13-jwt.sh#L281-L283)
- **Signature:** `jwt_parse_claims <token>`
- **Description:** Alias of jwt_get_payload. Returns JSON claims object.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `token` (`string`) | JWT token. |

## Return / Exit Value

- {string} JSON claims.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  jwt_parse_claims "${token}"
```

---

See also the full runnable example script: [`examples/13_jwt_example.sh`](../../examples/13_jwt_example.sh).
