# functions/13-jwt.sh

# Protect against double sourcing
if [[ -n "${_JWT_SH_SOURCED:-}" ]]; then
  return 0
fi
readonly _JWT_SH_SOURCED=1

# Ensure config & json are sourced if available
if [[ -f "${PROJECT_ROOT:-.}/config/config.sh" ]]; then
  source "${PROJECT_ROOT:-.}/config/config.sh"
fi
if [[ -f "${PROJECT_ROOT:-.}/functions/14-jq.sh" ]]; then
  source "${PROJECT_ROOT:-.}/functions/14-jq.sh"
fi

# Load datetime module
zmodload zsh/datetime 2>/dev/null

# Helper: Base64url encode
_b64url_encode() {
  local data="$1"
  if [[ -z "${data}" ]]; then
    data=$(cat)
  fi
  echo -n "${data}" | base64 | tr -d '\r\n=' | tr -- '+/' '-_'
}

# Helper: Base64url decode
_b64url_decode() {
  local data="$1"
  if [[ -z "${data}" ]]; then
    data=$(cat)
  fi
  local remainder=$(( ${#data} % 4 ))
  if (( remainder == 2 )); then
    data="${data}=="
  elif (( remainder == 3 )); then
    data="${data}="
  fi
  echo -n "${data}" | tr -- '-_' '+/' | base64 -d 2>/dev/null
}

# Helper: HMAC SHA256
_hmac_sha256() {
  local data="$1"
  local secret="$2"
  echo -n "${data}" | openssl dgst -sha256 -hmac "${secret}" -binary | _b64url_encode
}

# /**
#  * @function jwt_generate
#  * @description Generates a JSON Web Token (JWT) with HS256 signature using the specified payload and secret.
#  * @param {string} payload - JSON payload string.
#  * @param {string} [secret] - HMAC secret key (defaults to JWT_SECRET).
#  * @return {string} The generated JWT token string.
#  * @example
#  *   local token
#  *   token=$(jwt_generate '{"sub": "12345", "name": "Alice"}' "my-secret")
#  */
jwt_generate() {
  local payload="$1"
  local secret="${2:-${JWT_SECRET:-}}"
  if [[ -z "${secret}" ]]; then
    return 1
  fi
  
  local header='{"alg":"HS256","typ":"JWT"}'
  local hdr_b64
  hdr_b64=$(echo -n "${header}" | _b64url_encode)
  local pay_b64
  pay_b64=$(echo -n "${payload}" | _b64url_encode)
  
  local sig
  sig=$(_hmac_sha256 "${hdr_b64}.${pay_b64}" "${secret}")
  
  echo "${hdr_b64}.${pay_b64}.${sig}"
}

# /**
#  * @function jwt_decode
#  * @description Decodes a JWT token without verifying its signature.
#  * @param {string} token - The JWT token.
#  * @return {string} JSON object containing "header" and "payload".
#  * @example
#  *   jwt_decode "header.payload.signature"
#  */
jwt_decode() {
  local token="$1"
  local -a parts
  parts=( ${(s:.:)token} )
  if (( ${#parts} < 2 )); then
    return 1
  fi
  
  local hdr
  hdr=$(echo -n "${parts[1]}" | _b64url_decode)
  local pay
  pay=$(echo -n "${parts[2]}" | _b64url_decode)
  
  printf '{"header":%s,"payload":%s}\n' "${hdr}" "${pay}"
}

# /**
#  * @function jwt_get_header
#  * @description Extracts and decodes the header part of a JWT.
#  * @param {string} token - The JWT token.
#  * @return {string} JSON header object.
#  * @example
#  *   jwt_get_header "header.payload.signature"
#  */
jwt_get_header() {
  local token="$1"
  local -a parts
  parts=( ${(s:.:)token} )
  if (( ${#parts} < 1 )); then
    return 1
  fi
  echo -n "${parts[1]}" | _b64url_decode
}

# /**
#  * @function jwt_get_payload
#  * @description Extracts and decodes the payload part of a JWT.
#  * @param {string} token - The JWT token.
#  * @return {string} JSON payload object.
#  * @example
#  *   jwt_get_payload "header.payload.signature"
#  */
jwt_get_payload() {
  local token="$1"
  local -a parts
  parts=( ${(s:.:)token} )
  if (( ${#parts} < 2 )); then
    return 1
  fi
  echo -n "${parts[2]}" | _b64url_decode
}

# /**
#  * @function jwt_get_claim
#  * @description Retrieves the value of a specific claim key from the JWT payload.
#  * @param {string} token - The JWT token.
#  * @param {string} claim - Jq query path to the claim (e.g. '.sub' or '.exp').
#  * @return {string} The claim value.
#  * @example
#  *   local sub
#  *   sub=$(jwt_get_claim "token" ".sub")
#  */
jwt_get_claim() {
  local token="$1"
  local claim="$2"
  local payload
  payload=$(jwt_get_payload "${token}") || return 1
  if typeset -f json_get_value >/dev/null; then
    json_get_value "${payload}" "${claim}"
  else
    echo "${payload}" | jq -r "${claim}" 2>/dev/null
  fi
}

# /**
#  * @function jwt_verify
#  * @description Verifies the HS256 signature of a JWT using the specified secret.
#  * @param {string} token - The JWT token to verify.
#  * @param {string} [secret] - HMAC secret key (defaults to JWT_SECRET).
#  * @return {number} 0 if signature is valid, 1 otherwise.
#  * @example
#  *   if jwt_verify "${token}" "my-secret"; then
#  *     echo "Signature matches"
#  *   fi
#  */
jwt_verify() {
  local token="$1"
  local secret="${2:-${JWT_SECRET:-}}"
  if [[ -z "${secret}" ]]; then
    return 1
  fi
  
  local -a parts
  parts=( ${(s:.:)token} )
  if (( ${#parts} != 3 )); then
    return 1
  fi
  
  local expected_sig
  expected_sig=$(_hmac_sha256 "${parts[1]}.${parts[2]}" "${secret}")
  
  if [[ "${parts[3]}" == "${expected_sig}" ]]; then
    return 0
  else
    return 1
  fi
}

# /**
#  * @function jwt_expired
#  * @description Checks if a JWT is expired by comparing the 'exp' claim with the current time.
#  * @param {string} token - The JWT token.
#  * @return {number} 0 if expired, 1 if not expired or exp claim is missing.
#  * @example
#  *   if jwt_expired "${token}"; then
#  *     echo "Token has expired"
#  *   fi
#  */
jwt_expired() {
  local token="$1"
  local exp
  exp=$(jwt_get_claim "${token}" ".exp") || return 1
  if [[ -z "${exp}" || "${exp}" == "null" ]]; then
    return 1
  fi
  
  local now="${EPOCHSECONDS:-$(date +%s)}"
  if (( now >= exp )); then
    return 0
  else
    return 1
  fi
}

# /**
#  * @function jwt_valid
#  * @description Checks if a JWT signature is verified and the token is not expired.
#  * @param {string} token - The JWT token.
#  * @param {string} [secret] - HMAC secret key.
#  * @return {number} 0 if token is fully valid, 1 otherwise.
#  * @example
#  *   if jwt_valid "${token}"; then
#  *     echo "Token is valid"
#  *   fi
#  */
jwt_valid() {
  local token="$1"
  local secret="${2:-${JWT_SECRET:-}}"
  jwt_verify "${token}" "${secret}" && ! jwt_expired "${token}"
}

# /**
#  * @function jwt_refresh
#  * @description Updates the 'iat' and 'exp' claims of a JWT payload and signs it to return a refreshed token.
#  * @param {string} token - The JWT token to refresh.
#  * @param {string} [secret] - HMAC secret key.
#  * @return {string} The refreshed JWT token.
#  * @example
#  *   local new_token
#  *   new_token=$(jwt_refresh "${token}")
#  */
jwt_refresh() {
  local token="$1"
  local secret="${2:-${JWT_SECRET:-}}"
  local payload
  payload=$(jwt_get_payload "${token}") || return 1
  
  local now="${EPOCHSECONDS:-$(date +%s)}"
  local exp
  exp=$(jwt_get_claim "${token}" ".exp")
  local duration=3600
  if [[ -n "${exp}" && "${exp}" != "null" ]]; then
    local iat
    iat=$(jwt_get_claim "${token}" ".iat")
    if [[ -n "${iat}" && "${iat}" != "null" && $(( exp - iat )) -gt 0 ]]; then
      duration=$(( exp - iat ))
    fi
  fi
  local new_exp=$(( now + duration ))
  
  local new_payload
  new_payload=$(echo "${payload}" | jq --argjson iat "${now}" --argjson exp "${new_exp}" '.iat = $iat | .exp = $exp')
  jwt_generate "${new_payload}" "${secret}"
}

# /**
#  * @function jwt_parse_claims
#  * @description Alias of jwt_get_payload. Returns JSON claims object.
#  * @param {string} token - JWT token.
#  * @return {string} JSON claims.
#  * @example
#  *   jwt_parse_claims "${token}"
#  */
jwt_parse_claims() {
  jwt_get_payload "$1"
}

# /**
#  * @function jwt_get_audience
#  * @description Returns the 'aud' (audience) claim from the JWT token.
#  * @param {string} token - The JWT token.
#  * @return {string} The audience claim value.
#  * @example
#  *   local aud
#  *   aud=$(jwt_get_audience "${token}")
#  */
jwt_get_audience() {
  jwt_get_claim "$1" ".aud"
}

# /**
#  * @function jwt_get_issuer
#  * @description Returns the 'iss' (issuer) claim from the JWT token.
#  * @param {string} token - The JWT token.
#  * @return {string} The issuer claim value.
#  * @example
#  *   local iss
#  *   iss=$(jwt_get_issuer "${token}")
#  */
jwt_get_issuer() {
  jwt_get_claim "$1" ".iss"
}

# /**
#  * @function jwt_has_claim
#  * @description Checks if a specific claim exists and is not null in the JWT payload.
#  * @param {string} token - The JWT token.
#  * @param {string} claim - Jq query path to the claim.
#  * @return {number} 0 if claim exists, 1 otherwise.
#  * @example
#  *   if jwt_has_claim "${token}" ".role"; then
#  *     echo "Role is present"
#  *   fi
#  */
jwt_has_claim() {
  local token="$1"
  local claim="$2"
  local val
  val=$(jwt_get_claim "${token}" "${claim}")
  if [[ -n "${val}" && "${val}" != "null" ]]; then
    return 0
  else
    return 1
  fi
}
