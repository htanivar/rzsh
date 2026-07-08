#!/usr/bin/env zsh

# Core test runner for the Zsh script framework
SCRIPT_DIR="${0:A:h}"
PROJECT_ROOT="${SCRIPT_DIR}"

source "${PROJECT_ROOT}/config/config.sh"
init_config

echo "================================================================================"
echo " Running Zsh Framework Test Suite"
echo "================================================================================"

TOTAL_SCRIPTS_RUN=0
TOTAL_SCRIPTS_FAILED=0

# Ensure logs dir exists
mkdir -p "${LOG_DIR}"

# Run tests
for test_script in "${PROJECT_ROOT}/tests"/*.test.sh; do
  [[ -f "${test_script}" ]] || continue
  
  echo "Running test script: ${test_script:t}"
  zsh "${test_script}"
  exit_code=$?
  (( TOTAL_SCRIPTS_RUN++ ))
  if (( exit_code != 0 )); then
    echo "  ❌ ${test_script:t} FAILED"
    (( TOTAL_SCRIPTS_FAILED++ ))
  else
    echo "  ✅ ${test_script:t} PASSED"
  fi
  echo "--------------------------------------------------------------------------------"
done

echo "================================================================================"
echo " Test Suite Summary"
echo "================================================================================"
echo "Total scripts run:    ${TOTAL_SCRIPTS_RUN}"
echo "Scripts passed:       $(( TOTAL_SCRIPTS_RUN - TOTAL_SCRIPTS_FAILED ))"
echo "Scripts failed:       ${TOTAL_SCRIPTS_FAILED}"

if (( TOTAL_SCRIPTS_FAILED > 0 )); then
  echo "❌ Some test scripts failed!"
  exit 1
else
  echo "✅ All test scripts passed successfully!"
  exit 0
fi
