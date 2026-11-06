#!/usr/bin/env zsh
# tests/13-jwt.test.sh
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

# Source helpers, config, and target script via RZSH_DIR
my_dir="${${(%):-%x}:A:h}"
if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${my_dir:h}" >&2
  export RZSH_DIR="${my_dir:h}"
fi
source "${RZSH_DIR}/tests/test_helpers.sh"
source "${RZSH_DIR}/config/config.sh"
source "${RZSH_DIR}/functions/13-jwt.sh"

init_config

payload='{"sub":"12345","name":"Alice","exp":2000000000,"iss":"test-issuer","aud":"test-audience"}'
secret="test-secret"

test_jwt_generate_and_decode() {
  local token
  token=$(jwt_generate "${payload}" "${secret}")
  assert_true "[[ -n \"${token}\" ]]" "Generated token should not be empty"
  assert_true "[[ \"${token}\" == *.*.* ]]" "Token should have three parts"
  
  local decoded
  decoded=$(jwt_decode "${token}")
  local sub
  sub=$(echo "${decoded}" | jq -r ".payload.sub")
  assert_equals "12345" "${sub}" "Decoded subject should match"
}

test_jwt_verify() {
  local token
  token=$(jwt_generate "${payload}" "${secret}")
  assert_true "jwt_verify '${token}' '${secret}'" "Verification with correct secret should pass"
  assert_false "jwt_verify '${token}' 'wrong-secret'" "Verification with wrong secret should fail"
}

test_jwt_get_claim() {
  local token
  token=$(jwt_generate "${payload}" "${secret}")
  local iss
  iss=$(jwt_get_issuer "${token}")
  assert_equals "test-issuer" "${iss}" "Issuer should be test-issuer"
  
  local aud
  aud=$(jwt_get_audience "${token}")
  assert_equals "test-audience" "${aud}" "Audience should be test-audience"

  local hdr
  hdr=$(jwt_get_header "${token}")
  local alg
  alg=$(echo "${hdr}" | jq -r ".alg")
  assert_equals "HS256" "${alg}" "Header alg should be HS256"

  local pay
  pay=$(jwt_get_payload "${token}")
  local name
  name=$(echo "${pay}" | jq -r ".name")
  assert_equals "Alice" "${name}" "Payload name should be Alice"

  local claims
  claims=$(jwt_parse_claims "${token}")
  assert_equals "${pay}" "${claims}" "jwt_parse_claims should match jwt_get_payload"
}

test_jwt_expired_and_valid() {
  local token
  token=$(jwt_generate "${payload}" "${secret}")
  assert_false "jwt_expired '${token}'" "Token with far future exp should not be expired"
  assert_true "jwt_valid '${token}' '${secret}'" "Token should be valid"
  
  # Create expired token
  local exp_payload='{"sub":"123","exp":100}'
  local exp_token
  exp_token=$(jwt_generate "${exp_payload}" "${secret}")
  assert_true "jwt_expired '${exp_token}'" "Token with past exp should be expired"
  assert_false "jwt_valid '${exp_token}' '${secret}'" "Expired token should not be valid"
}

test_jwt_refresh() {
  local token
  token=$(jwt_generate "${payload}" "${secret}")
  local ref_token
  ref_token=$(jwt_refresh "${token}" "${secret}")
  
  local iat
  iat=$(jwt_get_claim "${ref_token}" ".iat")
  assert_true "[[ -n \"${iat}\" && \"${iat}\" != \"null\" ]]" "Refreshed token should have iat claim set"
}

test_jwt_has_claim() {
  local token
  token=$(jwt_generate "${payload}" "${secret}")
  assert_true "jwt_has_claim '${token}' '.name'" "Should confirm name claim exists"
  assert_false "jwt_has_claim '${token}' '.nonexistent'" "Should confirm nonexistent claim does not exist"
}

run_test test_jwt_generate_and_decode
run_test test_jwt_verify
run_test test_jwt_get_claim
run_test test_jwt_expired_and_valid
run_test test_jwt_refresh
run_test test_jwt_has_claim

exit $(( TESTS_FAILED > 0 ? 1 : 0 ))
