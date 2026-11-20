# JSON Web Tokens (JWT) — Function Index

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../13-jwt.md) › **13-jwt/** › [Runnable Example](../../examples/13_jwt_example.sh) › [Tests](../../tests/13-jwt.test.sh)

- **Source File:** [`functions/13-jwt.sh`](../../functions/13-jwt.sh)
- **Runnable Example:** [`examples/13_jwt_example.sh`](../../examples/13_jwt_example.sh)

| Function | Signature | Description |
| :--- | :--- | :--- |
| [`jwt_generate`](jwt_generate.md) | `jwt_generate <payload> [secret]` | Generates a JSON Web Token (JWT) with HS256 signature using the specified payload and secret. |
| [`jwt_decode`](jwt_decode.md) | `jwt_decode <token>` | Decodes a JWT token without verifying its signature. |
| [`jwt_get_header`](jwt_get_header.md) | `jwt_get_header <token>` | Extracts and decodes the header part of a JWT. |
| [`jwt_get_payload`](jwt_get_payload.md) | `jwt_get_payload <token>` | Extracts and decodes the payload part of a JWT. |
| [`jwt_get_claim`](jwt_get_claim.md) | `jwt_get_claim <token> <claim>` | Retrieves the value of a specific claim key from the JWT payload. |
| [`jwt_verify`](jwt_verify.md) | `jwt_verify <token> [secret]` | Verifies the HS256 signature of a JWT using the specified secret. |
| [`jwt_expired`](jwt_expired.md) | `jwt_expired <token>` | Checks if a JWT is expired by comparing the 'exp' claim with the current time. |
| [`jwt_valid`](jwt_valid.md) | `jwt_valid <token> [secret]` | Checks if a JWT signature is verified and the token is not expired. |
| [`jwt_refresh`](jwt_refresh.md) | `jwt_refresh <token> [secret]` | Updates the 'iat' and 'exp' claims of a JWT payload and signs it to return a refreshed token. |
| [`jwt_parse_claims`](jwt_parse_claims.md) | `jwt_parse_claims <token>` | Alias of jwt_get_payload. Returns JSON claims object. |
| [`jwt_get_audience`](jwt_get_audience.md) | `jwt_get_audience <token>` | Returns the 'aud' (audience) claim from the JWT token. |
| [`jwt_get_issuer`](jwt_get_issuer.md) | `jwt_get_issuer <token>` | Returns the 'iss' (issuer) claim from the JWT token. |
| [`jwt_has_claim`](jwt_has_claim.md) | `jwt_has_claim <token> <claim>` | Checks if a specific claim exists and is not null in the JWT payload. |
