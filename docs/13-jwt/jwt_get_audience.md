# `jwt_get_audience`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../13-jwt.md) › [Function Index](README.md) › **`jwt_get_audience`** › [Runnable Example](../../examples/13_jwt_example.sh) › [Tests](../../tests/13-jwt.test.sh)

- **Source:** [`functions/13-jwt.sh#L294-L296`](../../functions/13-jwt.sh#L294-L296)
- **Signature:** `jwt_get_audience <token>`
- **Description:** Returns the 'aud' (audience) claim from the JWT token.

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

- {string} The audience claim value.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local aud
  aud=$(jwt_get_audience "${token}")
```

---

See also the full runnable example script: [`examples/13_jwt_example.sh`](../../examples/13_jwt_example.sh).
