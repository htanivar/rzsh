#!/usr/bin/env zsh
# tests/99-evidences.test.sh
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

# Source helpers, config, and target script via RZSH_DIR
my_dir="${${(%):-%x}:A:h}"
if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${my_dir:h}" >&2
  export RZSH_DIR="${my_dir:h}"
fi
source "${RZSH_DIR}/tests/test_helpers.sh"
source "${RZSH_DIR}/config/config.sh"
source "${RZSH_DIR}/functions/99-evidences.sh"

init_config

test_evidence_lifecycle() {
  assert_true "init_evidence" "Evidence initialization should succeed"
  assert_true "[[ -d \"${CURRENT_EVIDENCE_DIR}\" ]]" "Evidence directory should exist"
  
  collect_environment_evidence
  assert_true "[[ -f \"${CURRENT_EVIDENCE_DIR}/environment.json\" ]]" "Environment evidence file should be created"
  
  collect_script_evidence "arg1" "arg2"
  assert_true "[[ -f \"${CURRENT_EVIDENCE_DIR}/script.json\" ]]" "Script evidence file should be created"
  
  collect_network_evidence
  assert_true "[[ -f \"${CURRENT_EVIDENCE_DIR}/network.json\" ]]" "Network evidence file should be created"
  
  local dummy_file="${PROJECT_ROOT}/logs/test_ev_dummy.txt"
  echo "dummy text" > "${dummy_file}"
  collect_file_evidence "${dummy_file}"
  assert_true "[[ -f \"${CURRENT_EVIDENCE_DIR}/files.json\" ]]" "Files evidence file should be created"
  rm -f "${dummy_file}"
  
  collect_git_evidence
  assert_true "[[ -f \"${CURRENT_EVIDENCE_DIR}/git.json\" ]]" "Git evidence file should be created"
  
  collect_docker_evidence
  assert_true "[[ -f \"${CURRENT_EVIDENCE_DIR}/docker.json\" ]]" "Docker evidence file should be created"
  
  collect_custom_evidence '{"custom_key":"custom_val"}'
  assert_true "[[ -f \"${CURRENT_EVIDENCE_DIR}/custom.json\" ]]" "Custom evidence file should be created"
  
  # Check consolidated JSON
  local combined
  combined=$(evidence_to_json)
  assert_true "evidence_validate '${combined}'" "Consolidated JSON should be valid"
  
  # Check MD report via both evidence_to_markdown and generate_evidence_report
  local md
  md=$(evidence_to_markdown)
  assert_true "[[ \"${md}\" == *\"# System Evidence Report\"* ]]" "evidence_to_markdown should return markdown header"
  md=$(generate_evidence_report)
  assert_true "[[ -f \"${CURRENT_EVIDENCE_DIR}/report.md\" ]]" "Report.md should be created"
  
  # Check evidence_compare
  local modified_json
  modified_json=$(echo "${combined}" | jq '.custom.custom_key = "changed_val"')
  local diff_out
  diff_out=$(evidence_compare "${combined}" "${modified_json}")
  assert_true "[[ \"${diff_out}\" == *\"changed_val\"* ]]" "evidence_compare should show JSON difference"
  
  # Check Archive
  local archive
  archive=$(evidence_archive)
  assert_true "[[ -f \"${archive}\" ]]" "Archive file should exist"
  
  # Cleanup
  rm -rf "${CURRENT_EVIDENCE_DIR}" "${archive}"
}

run_test test_evidence_lifecycle

exit $(( TESTS_FAILED > 0 ? 1 : 0 ))
