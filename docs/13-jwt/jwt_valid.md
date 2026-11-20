# `jwt_valid`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../13-jwt.md) › [Function Index](README.md) › **`jwt_valid`** › [Runnable Example](../../examples/13_jwt_example.sh) › [Tests](../../tests/13-jwt.test.sh)

- **Source:** [`functions/13-jwt.sh#L233-L237`](../../functions/13-jwt.sh#L233-L237)
- **Signature:** `jwt_valid <token> [secret]`
- **Description:** Checks if a JWT signature is verified and the token is not expired.

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
| `[secret]` (`string`) | HMAC secret key. |

## Return / Exit Value

- {number} 0 if token is fully valid, 1 otherwise.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  if jwt_valid "${token}"; then
    echo "Token is valid"
  fi
```

---

See also the full runnable example script: [`examples/13_jwt_example.sh`](../../examples/13_jwt_example.sh).
