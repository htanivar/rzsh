#!/usr/bin/env zsh
# tests/19-compare-three-branches.test.sh
# Breadcrumb: README.md -> GLOSSARY.md -> docs/05-git.md -> examples/05_git_example.sh -> tests/19-compare-three-branches.test.sh
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

my_dir="${${(%):-%x}:A:h}"
if [[ -z "${RZSH_DIR:-}" ]]; then
  export RZSH_DIR="${my_dir:h}"
fi
source "${RZSH_DIR}/tests/test_helpers.sh"
source "${RZSH_DIR}/config/config.sh"
init_config

original_pwd="${PWD}"
test_git_dir="${PROJECT_ROOT}/logs/test_compare_three_branches_repo"
rm -rf "${test_git_dir}"
mkdir -p "${test_git_dir}"

cd "${test_git_dir}"
git init -b develop >/dev/null 2>&1
git config user.email "test@example.com"
git config user.name "Test User"

echo "base" > app.txt
git add app.txt
git commit -m "chore: initial commit on develop" >/dev/null 2>&1

# Create release/2.1.0 (x-1) with two commits: fix1 (cherry-picked to develop) and fix2 (missed everywhere)
git checkout -b release/2.1.0 >/dev/null 2>&1
echo "fix1-content" > fix1.txt
git add fix1.txt
git commit -m "fix: backported hotfix one on release 2.1.0" >/dev/null 2>&1
fix1_sha=$(git rev-parse HEAD)

echo "fix2-missed-content" > fix2.txt
git add fix2.txt
git commit -m "fix: missed hotfix two on release 2.1.0" >/dev/null 2>&1

# Advance develop: cherry-pick fix1 and add a new feature before cutting release/2.2.0
git checkout develop >/dev/null 2>&1
git cherry-pick "${fix1_sha}" >/dev/null 2>&1
echo "feature-22" > feature22.txt
git add feature22.txt
git commit -m "feat: new feature on develop" >/dev/null 2>&1

# Cut release/2.2.0 (x) from develop and add fix3 (not backported to develop)
git checkout -b release/2.2.0 >/dev/null 2>&1
echo "fix3-release22-content" > fix3.txt
git add fix3.txt
git commit -m "fix: hotfix three on release 2.2.0" >/dev/null 2>&1
git checkout develop >/dev/null 2>&1

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local msg="$3"
  if [[ "${haystack}" != *"${needle}"* ]]; then
    printf "\n    \e[31mAssertion failed: %s\e[0m\n" "${msg}" >&2
    printf "      Expected to find: '%s'\n" "${needle}" >&2
    return 1
  fi
  return 0
}

assert_not_contains() {
  local haystack="$1"
  local needle="$2"
  local msg="$3"
  if [[ "${haystack}" == *"${needle}"* ]]; then
    printf "\n    \e[31mAssertion failed: %s\e[0m\n" "${msg}" >&2
    printf "      Did not expect to find: '%s'\n" "${needle}" >&2
    return 1
  fi
  return 0
}

test_compare_three_branches_explicit_default() {
  local report_file="${test_git_dir}/three_way_report.md"
  local stdout_out
  stdout_out=$(git_compare_three_branches --output "${report_file}" "release/2.2.0" "release/2.1.0" "develop" 2>/dev/null)
  local exit_code=$?

  assert_equals 0 "${exit_code}" "git_compare_three_branches should exit 0"
  assert_true "[[ -f \"${report_file}\" ]]" "Report file should be created"

  local report
  report=$(cat "${report_file}")

  # Verify all 3 links are present in the summary and body
  assert_contains "${report}" "\`release/2.2.0 -> develop\`" "Summary should include release/2.2.0 -> develop"
  assert_contains "${report}" "\`release/2.1.0 -> develop\`" "Summary should include release/2.1.0 -> develop"
  assert_contains "${report}" "\`release/2.1.0 -> release/2.2.0\`" "Summary should include release/2.1.0 -> release/2.2.0"

  # Verify missing commits and their patch content
  assert_contains "${report}" "fix: hotfix three on release 2.2.0" "Report should list fix3 missing from develop"
  assert_contains "${report}" "fix3-release22-content" "Report should include diff content of fix3"
  assert_contains "${report}" "fix: missed hotfix two on release 2.1.0" "Report should list fix2 missing from develop and release/2.2.0"
  assert_contains "${report}" "fix2-missed-content" "Report should include diff content of fix2"

  # Verify cherry-picked fix1 is NOT flagged as a missing commit
  assert_not_contains "${report}" "fix: backported hotfix one on release 2.1.0" "Cherry-picked fix1 should not be reported as missing"

  # Verify branch-level content comparison section from git_compare_branches is included
  assert_contains "${report}" "Branch Content Comparison" "Report should include branch-level content comparison"
  assert_contains "${stdout_out}" "3-Branch Release Comparison Report" "Terminal output should include report header"
}

test_compare_three_branches_autodetect_and_silent() {
  local report_file="${test_git_dir}/three_way_silent.md"
  local stdout_out
  stdout_out=$(git_compare_three_branches --silent --output "${report_file}" "release/2.2.0" "release/2.1.0" 2>/dev/null)
  local exit_code=$?

  assert_equals 0 "${exit_code}" "Auto-detect + silent mode should exit 0"
  assert_equals "" "${stdout_out}" "Silent mode should suppress stdout"
  assert_true "[[ -f \"${report_file}\" ]]" "Silent mode should still write report file"

  local report
  report=$(cat "${report_file}")
  assert_contains "${report}" "**Default Branch:** \`develop\`" "Should auto-detect develop as default branch"
}

test_compare_three_branches_invalid_args() {
  git_compare_three_branches "release/2.2.0" >/dev/null 2>&1
  assert_equals 1 "$?" "Should fail with fewer than 2 branches"

  git_compare_three_branches "release/2.2.0" "nonexistent/branch" "develop" >/dev/null 2>&1
  assert_equals 1 "$?" "Should fail when a branch does not exist"
}

run_test test_compare_three_branches_explicit_default
run_test test_compare_three_branches_autodetect_and_silent
run_test test_compare_three_branches_invalid_args

cd "${original_pwd}"
rm -rf "${test_git_dir}"

exit $(( TESTS_FAILED > 0 ? 1 : 0 ))
