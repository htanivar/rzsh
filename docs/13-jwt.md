# JSON Web Tokens Module Reference

- **Source File:** [`functions/13-jwt.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/13-jwt.sh)
- **Description:** HS256 generation, signature verification, claims, expiration checking.

---

## Detailed Usage Examples

### Integration Setup
To use the JSON Web Tokens module, ensure the global configurations are initialized, then source the script file:

```zsh
source ./config/config.sh
init_config

source ./functions/13-jwt.sh
```

---

## Function Signatures & Descriptions

### `jwt_generate`

* **Signature:** `jwt_generate <json_payload> [secret]`
* **Description:** Generates a signed HS256 JWT using the payload and secret key (uses base64url tr encoding escape fix).

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
### `jwt_get_audience / jwt_get_issuer`

* **Signature:** `jwt_get_audience <token> / jwt_get_issuer <token>`
* **Description:** Queries aud or iss claim properties directly.

#### Example Code:
```zsh
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
