# `jwt_generate`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../13-jwt.md) › [Function Index](README.md) › **`jwt_generate`** › [Runnable Example](../../examples/13_jwt_example.sh) › [Tests](../../tests/13-jwt.test.sh)

- **Source:** [`functions/13-jwt.sh#L61-L78`](../../functions/13-jwt.sh#L61-L78)
- **Signature:** `jwt_generate <payload> [secret]`
- **Description:** Generates a JSON Web Token (JWT) with HS256 signature using the specified payload and secret.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `payload` (`string`) | JSON payload string. |
| `[secret]` (`string`) | HMAC secret key (defaults to JWT_SECRET). |

## Return / Exit Value

- {string} The generated JWT token string.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local token
  token=$(jwt_generate '{"sub": "12345", "name": "Alice"}' "my-secret")
```

---

See also the full runnable example script: [`examples/13_jwt_example.sh`](../../examples/13_jwt_example.sh).
