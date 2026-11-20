# `jwt_expired`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../13-jwt.md) › [Function Index](README.md) › **`jwt_expired`** › [Runnable Example](../../examples/13_jwt_example.sh) › [Tests](../../tests/13-jwt.test.sh)

- **Source:** [`functions/13-jwt.sh#L206-L220`](../../functions/13-jwt.sh#L206-L220)
- **Signature:** `jwt_expired <token>`
- **Description:** Checks if a JWT is expired by comparing the 'exp' claim with the current time.

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

- {number} 0 if expired, 1 if not expired or exp claim is missing.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  if jwt_expired "${token}"; then
    echo "Token has expired"
  fi
```

---

See also the full runnable example script: [`examples/13_jwt_example.sh`](../../examples/13_jwt_example.sh).
