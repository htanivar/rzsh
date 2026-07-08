# tests/05-git.test.sh

# Source helpers, config, and target script
local my_dir="${${(%):-%x}:A:h}"
source "${my_dir}/test_helpers.sh"
source "${my_dir}/../config/config.sh"
source "${my_dir}/../functions/05-git.sh"

init_config

# Setup temporary test Git repo
local original_pwd="${PWD}"
local test_git_dir="${PROJECT_ROOT}/logs/test_git_repo"
rm -rf "${test_git_dir}"
mkdir -p "${test_git_dir}"

cd "${test_git_dir}"
git init -b main
git config user.email "test@example.com"
git config user.name "Test User"
echo "hello" > file.txt
git add file.txt
git commit -m "initial commit"

test_git_get_current_branch() {
  local br
  br=$(git_get_current_branch)
  assert_equals "main" "${br}" "Current branch should be main"
}

test_git_is_clean() {
  assert_true "git_is_clean" "Repo should be clean"
  echo "dirty" >> file.txt
  assert_false "git_is_clean" "Repo should be dirty after file change"
  git checkout -- file.txt
}

test_git_get_root() {
  local root
  root=$(git_get_root)
  assert_equals "${test_git_dir}" "${root}" "git_get_root should be the test repo dir"
}

test_git_status_message() {
  echo "new file" > new.txt
  local msg
  msg=$(git_status_message)
  assert_true "[[ -n \"${msg}\" ]]" "Status message should not be empty when dirty"
  rm -f new.txt
}

test_git_commit() {
  echo "new data" > file.txt
  git_commit "second commit"
  local msg
  msg=$(git_get_commit_message "HEAD")
  assert_equals "second commit" "${msg}" "Commit message should match"
}

test_git_branch_exists() {
  assert_true "git_branch_exists 'main'" "Branch main should exist"
  assert_false "git_branch_exists 'nonexistent'" "Branch nonexistent should not exist"
}

test_git_get_commit_hash() {
  local h
  h=$(git_get_commit_hash)
  assert_equals 40 ${#h} "Commit hash should be 40 characters long"
}

run_test test_git_get_current_branch
run_test test_git_is_clean
run_test test_git_get_root
run_test test_git_status_message
run_test test_git_commit
run_test test_git_branch_exists
run_test test_git_get_commit_hash

# Cleanup
cd "${original_pwd}"
rm -rf "${test_git_dir}"

exit $(( TESTS_FAILED > 0 ? 1 : 0 ))
