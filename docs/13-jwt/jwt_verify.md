# `jwt_verify`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../13-jwt.md) › [Function Index](README.md) › **`jwt_verify`** › [Runnable Example](../../examples/13_jwt_example.sh) › [Tests](../../tests/13-jwt.test.sh)

- **Source:** [`functions/13-jwt.sh#L173-L194`](../../functions/13-jwt.sh#L173-L194)
- **Signature:** `jwt_verify <token> [secret]`
- **Description:** Verifies the HS256 signature of a JWT using the specified secret.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `token` (`string`) | The JWT token to verify. |
| `[secret]` (`string`) | HMAC secret key (defaults to JWT_SECRET). |

## Return / Exit Value

- {number} 0 if signature is valid, 1 otherwise.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  if jwt_verify "${token}" "my-secret"; then
    echo "Signature matches"
  fi
```

---

See also the full runnable example script: [`examples/13_jwt_example.sh`](../../examples/13_jwt_example.sh).
