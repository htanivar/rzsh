#!/usr/bin/env zsh
# tests/16-release-backport.test.sh
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

my_dir="${${(%):-%x}:A:h}"
if [[ -z "${RZSH_DIR:-}" ]]; then
  export RZSH_DIR="${my_dir:h}"
fi
source "${RZSH_DIR}/tests/test_helpers.sh"
source "${RZSH_DIR}/config/config.sh"
init_config

original_pwd="${PWD}"
test_git_dir="${PROJECT_ROOT}/logs/test_release_backport_repo"
rm -rf "${test_git_dir}"
mkdir -p "${test_git_dir}"

cd "${test_git_dir}"
git init -b develop
git config user.email "test@example.com"
git config user.name "Test User"

echo "base" > app.txt
git add app.txt
git commit -m "chore: initial commit on develop"

# Create release/1.0.0 with two commits: one cherry-picked to develop, one missed
git checkout -b release/1.0.0
echo "fix1" > fix1.txt
git add fix1.txt
git commit -m "fix: hotfix one on release 1.0.0"
fix1_sha=$(git rev-parse HEAD)

echo "fix2" > fix2.txt
git add fix2.txt
git commit -m "fix: missed hotfix two on release 1.0.0"

# Create release/1.1.0 from develop with its own commit
git checkout develop
git cherry-pick "${fix1_sha}" >/dev/null 2>&1
git checkout -b release/1.1.0
echo "rel11" > rel11.txt
git add rel11.txt
git commit -m "feat: release 1.1.0 change"
git checkout develop

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

test_detect_default_branch() {
  local detected
  detected=$(git_detect_default_branch)
  assert_equals "develop" "${detected}" "Should detect develop as default branch"
}

test_check_release_backport_default_target() {
  local -a rel_b
  rel_b=( ${(f)"$(git_list_branches "release/*")"} )
  local idx_release=${rel_b[(Ie)release/1.0.0]}

  local output
  output=$(printf "n\n%s\n" "${idx_release}" | zsh "${RZSH_DIR}/scripts/04-git/check_release_backport.sh" 2>/dev/null)
  local exit_code=$?

  assert_equals 0 "${exit_code}" "check_release_backport.sh should exit 0"
  assert_true "[[ -f \"./logs/backport_report.md\" ]]" "Report file should be created at ./logs/backport_report.md"
  assert_contains "${output}" "fix: missed hotfix two on release 1.0.0" "Output should highlight missed commit"
  assert_not_contains "${output}" "fix: hotfix one on release 1.0.0" "Output should exclude cherry-picked commit"

  local report_content
  report_content=$(cat "./logs/backport_report.md")
  assert_contains "${report_content}" "**Missing (Not Backported):** 1" "Report should count 1 missing commit"
}

test_check_release_backport_two_release_branches() {
  local -a all_b rel_b
  all_b=( ${(f)"$(git_list_branches)"} )
  rel_b=( ${(f)"$(git_list_branches "release/*")"} )
  local idx_target=${all_b[(Ie)release/1.1.0]}
  local idx_release=${rel_b[(Ie)release/1.0.0]}

  printf "y\n%s\n%s\n" "${idx_target}" "${idx_release}" | \
    zsh "${RZSH_DIR}/scripts/04-git/check_release_backport.sh" >/dev/null 2>&1
  local exit_code=$?

  assert_equals 0 "${exit_code}" "Interactive comparison between 2 release branches should exit 0"
  local report_content
  report_content=$(cat "./logs/backport_report.md")
  assert_contains "${report_content}" "**Target Branch:** \`release/1.1.0\`" "Target branch should be changed to release/1.1.0"
  assert_contains "${report_content}" "**Release Branch:** \`release/1.0.0\`" "Release branch should be release/1.0.0"
  assert_contains "${report_content}" "fix: missed hotfix two on release 1.0.0" "Should report commit missing in release/1.1.0"
}

run_test test_detect_default_branch
run_test test_check_release_backport_default_target
run_test test_check_release_backport_two_release_branches

cd "${original_pwd}"
rm -rf "${test_git_dir}"

exit $(( TESTS_FAILED > 0 ? 1 : 0 ))
