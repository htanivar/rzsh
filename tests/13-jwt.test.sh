# tests/13-jwt.test.sh

# Source helpers, config, and target script
local my_dir="${${(%):-%x}:A:h}"
source "${my_dir}/test_helpers.sh"
source "${my_dir}/../config/config.sh"
source "${my_dir}/../functions/13-jwt.sh"

init_config

local payload='{"sub":"12345","name":"Alice","exp":2000000000,"iss":"test-issuer","aud":"test-audience"}'
local secret="test-secret"

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
