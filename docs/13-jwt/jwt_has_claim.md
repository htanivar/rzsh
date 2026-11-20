# `jwt_has_claim`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../13-jwt.md) › [Function Index](README.md) › **`jwt_has_claim`** › [Runnable Example](../../examples/13_jwt_example.sh) › [Tests](../../tests/13-jwt.test.sh)

- **Source:** [`functions/13-jwt.sh#L322-L332`](../../functions/13-jwt.sh#L322-L332)
- **Signature:** `jwt_has_claim <token> <claim>`
- **Description:** Checks if a specific claim exists and is not null in the JWT payload.

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
| `claim` (`string`) | Jq query path to the claim. |

## Return / Exit Value

- {number} 0 if claim exists, 1 otherwise.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  if jwt_has_claim "${token}" ".role"; then
    echo "Role is present"
  fi
```

---

See also the full runnable example script: [`examples/13_jwt_example.sh`](../../examples/13_jwt_example.sh).
