# `jwt_refresh`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../13-jwt.md) › [Function Index](README.md) › **`jwt_refresh`** › [Runnable Example](../../examples/13_jwt_example.sh) › [Tests](../../tests/13-jwt.test.sh)

- **Source:** [`functions/13-jwt.sh#L249-L271`](../../functions/13-jwt.sh#L249-L271)
- **Signature:** `jwt_refresh <token> [secret]`
- **Description:** Updates the 'iat' and 'exp' claims of a JWT payload and signs it to return a refreshed token.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `token` (`string`) | The JWT token to refresh. |
| `[secret]` (`string`) | HMAC secret key. |

## Return / Exit Value

- {string} The refreshed JWT token.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local new_token
  new_token=$(jwt_refresh "${token}")
```

---

See also the full runnable example script: [`examples/13_jwt_example.sh`](../../examples/13_jwt_example.sh).
