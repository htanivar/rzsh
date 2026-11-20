# `jwt_get_claim`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../13-jwt.md) › [Function Index](README.md) › **`jwt_get_claim`** › [Runnable Example](../../examples/13_jwt_example.sh) › [Tests](../../tests/13-jwt.test.sh)

- **Source:** [`functions/13-jwt.sh#L150-L160`](../../functions/13-jwt.sh#L150-L160)
- **Signature:** `jwt_get_claim <token> <claim>`
- **Description:** Retrieves the value of a specific claim key from the JWT payload.

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
| `claim` (`string`) | Jq query path to the claim (e.g. '.sub' or '.exp'). |

## Return / Exit Value

- {string} The claim value.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local sub
  sub=$(jwt_get_claim "token" ".sub")
```

---

See also the full runnable example script: [`examples/13_jwt_example.sh`](../../examples/13_jwt_example.sh).
