# tests/15-compare-branches.test.sh

# Source helpers, config, and target script
local my_dir="${${(%):-%x}:A:h}"
source "${my_dir}/test_helpers.sh"
source "${my_dir}/../config/config.sh"

init_config

# Setup temporary test Git repo
local original_pwd="${PWD}"
local test_git_dir="${PROJECT_ROOT}/logs/test_compare_branches_repo"
rm -rf "${test_git_dir}"
mkdir -p "${test_git_dir}"

cd "${test_git_dir}"
git init -b main
git config user.email "test@example.com"
git config user.name "Test User"

# Initial files on main
echo "hello" > file_to_modify.txt
echo "delete me" > file_to_delete.txt
echo "rename me" > file_to_rename.txt
git add file_to_modify.txt file_to_delete.txt file_to_rename.txt
git commit -m "initial commit on main"

# Create feature branch
git checkout -b feature

# Make changes on feature branch
echo "hello modified" > file_to_modify.txt
rm file_to_delete.txt
git rm file_to_delete.txt
git mv file_to_rename.txt file_renamed.txt
echo "new file contents" > file_added.txt
git add file_to_modify.txt file_added.txt
git commit -m "feature commit"

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

test_compare_branches_execution() {
  local report_file="${test_git_dir}/report.md"
  
  # Run the comparison script from the test repo directory comparing main with feature
  zsh "${PROJECT_ROOT}/scripts/04-git/compare_branches.sh" main feature -o "${report_file}" -s
  local exit_code=$?
  
  assert_equals 0 "${exit_code}" "compare_branches.sh should exit with code 0"
  assert_true "[[ -f \"${report_file}\" ]]" "Generated report file should exist"
  
  # Check report contents
  local report_content
  report_content=$(cat "${report_file}")
  
  assert_contains "${report_content}" "### Added Files" "Report should have Added Files section"
  assert_contains "${report_content}" "- file_added.txt" "Report should list file_added.txt"
  assert_contains "${report_content}" "### Modified Files" "Report should have Modified Files section"
  assert_contains "${report_content}" "- file_to_modify.txt" "Report should list file_to_modify.txt"
  assert_contains "${report_content}" "### Deleted Files" "Report should have Deleted Files section"
  assert_contains "${report_content}" "- file_to_delete.txt" "Report should list file_to_delete.txt"
  assert_contains "${report_content}" "### Renamed Files" "Report should have Renamed Files section"
  assert_contains "${report_content}" "- file_to_rename.txt -> file_renamed.txt" "Report should list rename transition"
  assert_contains "${report_content}" "## Detailed Content Changes" "Report should have Detailed Content Changes section"
}

test_git_compare_branches_function() {
  local report_file="${test_git_dir}/report_func.md"
  
  # Source functions
  source "${PROJECT_ROOT}/functions/05-git.sh"
  
  # Run the comparison function directly comparing main with feature
  git_compare_branches main feature -o "${report_file}" -s
  local exit_code=$?
  
  assert_equals 0 "${exit_code}" "git_compare_branches function should exit with code 0"
  assert_true "[[ -f \"${report_file}\" ]]" "Generated function report file should exist"
  
  # Check report contents
  local report_content
  report_content=$(cat "${report_file}")
  
  assert_contains "${report_content}" "### Added Files" "Function report should have Added Files section"
  assert_contains "${report_content}" "- file_added.txt" "Function report should list file_added.txt"
  assert_contains "${report_content}" "### Modified Files" "Function report should have Modified Files section"
  assert_contains "${report_content}" "- file_to_modify.txt" "Function report should list file_to_modify.txt"
  assert_contains "${report_content}" "### Deleted Files" "Function report should have Deleted Files section"
  assert_contains "${report_content}" "- file_to_delete.txt" "Function report should list file_to_delete.txt"
  assert_contains "${report_content}" "### Renamed Files" "Function report should have Renamed Files section"
  assert_contains "${report_content}" "- file_to_rename.txt -> file_renamed.txt" "Function report should list rename transition"
  assert_contains "${report_content}" "## Detailed Content Changes" "Function report should have Detailed Content Changes section"
}

run_test test_compare_branches_execution
run_test test_git_compare_branches_function

# Cleanup
cd "${original_pwd}"
rm -rf "${test_git_dir}"

exit $(( TESTS_FAILED > 0 ? 1 : 0 ))
