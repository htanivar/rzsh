# JSON Web Tokens Module Reference

**Navigation:** [README](../README.md) › [GLOSSARY](../GLOSSARY.md) › **13-jwt.md** › [Example](../examples/13_jwt_example.sh) › [Tests](../tests/13-jwt.test.sh)

- **Source File:** [`functions/13-jwt.sh`](../functions/13-jwt.sh)
- **Description:** HS256 generation, signature verification, claims, expiration checking.

---

## Detailed Usage Examples

### Integration Setup
To use the JSON Web Tokens module, source the configuration script via `RZSH_DIR`, which automatically imports it:

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

---

## Module Variables (Keys)

| Variable Key | Description |
| :--- | :--- |
| `JWT_SECRET` | Default HMAC-SHA256 secret key used when no explicit secret parameter is passed to `jwt_generate`, `jwt_verify`, `jwt_valid`, or `jwt_refresh`. |

---

## Function Signatures & Descriptions

### `jwt_generate`

* **Signature:** `jwt_generate <json_payload> [secret]`
* **Description:** Generates a signed HS256 JWT using the payload and secret key.

#### Example Code:
```zsh
local token=$(jwt_generate '{"sub":"123","role":"admin"}' "secret")
```

---
### `jwt_decode`

* **Signature:** `jwt_decode <token>`
* **Description:** Decodes and outputs the header and payload segments of a JWT without performing verification.

#### Example Code:
```zsh
jwt_decode "${token}"
```

---
### `jwt_get_header / jwt_get_payload`

* **Signature:** `jwt_get_header <token> / jwt_get_payload <token>`
* **Description:** Extracts the header or payload components.

#### Example Code:
```zsh
local payload=$(jwt_get_payload "${token}")
```

---
### `jwt_get_claim`

* **Signature:** `jwt_get_claim <token> <jq_claim>`
* **Description:** Extracts specific property from the JWT payload segment.

#### Example Code:
```zsh
local sub=$(jwt_get_claim "${token}" ".sub")
```

---
### `jwt_verify`

* **Signature:** `jwt_verify <token> [secret]`
* **Description:** Returns 0 if the signature corresponds to the secret, 1 otherwise.

#### Example Code:
```zsh
jwt_verify "${token}" "secret" && echo "Verified!"
```

---
### `jwt_expired / jwt_valid`

* **Signature:** `jwt_expired <token> / jwt_valid <token> [secret]`
* **Description:** Checks token expiration, or performs full validation (both signature and expiration checking).

#### Example Code:
```zsh
jwt_valid "${token}" "secret" && echo "Authorized!"
```

---
### `jwt_refresh`

* **Signature:** `jwt_refresh <token> [secret]`
* **Description:** Generates a refreshed token with updated 'iat' and 'exp' claims.

#### Example Code:
```zsh
local renewed=$(jwt_refresh "${token}" "secret")
```

---
### `jwt_parse_claims / jwt_get_audience / jwt_get_issuer`

* **Signature:** `jwt_parse_claims <token> / jwt_get_audience <token> / jwt_get_issuer <token>`
* **Description:** Parses all payload claims into `key=value` lines (`jwt_parse_claims`), or queries `aud` / `iss` claim properties directly.

#### Example Code:
```zsh
jwt_parse_claims "${token}"
local issuer=$(jwt_get_issuer "${token}")
```

---
### `jwt_has_claim`

* **Signature:** `jwt_has_claim <token> <jq_claim>`
* **Description:** Returns 0 if the claim exists and is not null in the token, 1 otherwise.

#### Example Code:
```zsh
jwt_has_claim "${token}" ".role"
```

---

---

## Per-Function Copy-Paste Reference

Browse dedicated per-function pages with all flags and copy-paste variations in [`docs/13-jwt/`](13-jwt/README.md), or run [`examples/13_jwt_example.sh`](../examples/13_jwt_example.sh).

| Function | Per-Function Docs & Flags | Runnable Example |
| :--- | :--- | :--- |
| `jwt_generate` | [Docs & Examples](13-jwt/jwt_generate.md) | [`13_jwt_example.sh`](../examples/13_jwt_example.sh) |
| `jwt_decode` | [Docs & Examples](13-jwt/jwt_decode.md) | [`13_jwt_example.sh`](../examples/13_jwt_example.sh) |
| `jwt_get_header` | [Docs & Examples](13-jwt/jwt_get_header.md) | [`13_jwt_example.sh`](../examples/13_jwt_example.sh) |
| `jwt_get_payload` | [Docs & Examples](13-jwt/jwt_get_payload.md) | [`13_jwt_example.sh`](../examples/13_jwt_example.sh) |
| `jwt_get_claim` | [Docs & Examples](13-jwt/jwt_get_claim.md) | [`13_jwt_example.sh`](../examples/13_jwt_example.sh) |
| `jwt_verify` | [Docs & Examples](13-jwt/jwt_verify.md) | [`13_jwt_example.sh`](../examples/13_jwt_example.sh) |
| `jwt_expired` | [Docs & Examples](13-jwt/jwt_expired.md) | [`13_jwt_example.sh`](../examples/13_jwt_example.sh) |
| `jwt_valid` | [Docs & Examples](13-jwt/jwt_valid.md) | [`13_jwt_example.sh`](../examples/13_jwt_example.sh) |
| `jwt_refresh` | [Docs & Examples](13-jwt/jwt_refresh.md) | [`13_jwt_example.sh`](../examples/13_jwt_example.sh) |
| `jwt_parse_claims` | [Docs & Examples](13-jwt/jwt_parse_claims.md) | [`13_jwt_example.sh`](../examples/13_jwt_example.sh) |
| `jwt_get_audience` | [Docs & Examples](13-jwt/jwt_get_audience.md) | [`13_jwt_example.sh`](../examples/13_jwt_example.sh) |
| `jwt_get_issuer` | [Docs & Examples](13-jwt/jwt_get_issuer.md) | [`13_jwt_example.sh`](../examples/13_jwt_example.sh) |
| `jwt_has_claim` | [Docs & Examples](13-jwt/jwt_has_claim.md) | [`13_jwt_example.sh`](../examples/13_jwt_example.sh) |