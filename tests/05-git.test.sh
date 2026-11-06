#!/usr/bin/env zsh
# tests/05-git.test.sh
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

# Source helpers, config, and target script via RZSH_DIR
my_dir="${${(%):-%x}:A:h}"
if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${my_dir:h}" >&2
  export RZSH_DIR="${my_dir:h}"
fi
source "${RZSH_DIR}/tests/test_helpers.sh"
source "${RZSH_DIR}/config/config.sh"
source "${RZSH_DIR}/functions/05-git.sh"

init_config

# Setup temporary test Git repo
original_pwd="${PWD}"
test_git_dir="${PROJECT_ROOT}/logs/test_git_repo"
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

test_git_get_commit_message() {
  local msg
  msg=$(git_get_commit_message)
  assert_true "[[ -n \"${msg}\" ]]" "Commit message for HEAD should not be empty"
}

test_git_push_pull_and_safe_pull() {
  local bare_dir="${PROJECT_ROOT}/logs/test_git_bare.git"
  local clone_dir="${PROJECT_ROOT}/logs/test_git_clone"
  rm -rf "${bare_dir}" "${clone_dir}"
  git init --bare -b main "${bare_dir}" &>/dev/null

  git remote add origin "${bare_dir}" 2>/dev/null || git remote set-url origin "${bare_dir}"
  assert_true "git_push &>/dev/null" "git_push should push current branch to origin"

  # Clone to a second repo, commit & push a change so we can test git_pull and git_safe_pull
  git clone "${bare_dir}" "${clone_dir}" &>/dev/null
  (
    cd "${clone_dir}"
    git config user.email "test@example.com"
    git config user.name "Test User"
    echo "remote update 1" >> file.txt
    git add file.txt
    git commit -m "remote commit 1" &>/dev/null
    git push origin main &>/dev/null
  )

  assert_true "git_pull &>/dev/null" "git_pull should pull changes from origin"
  local msg
  msg=$(git_get_commit_message "HEAD")
  assert_equals "remote commit 1" "${msg}" "HEAD should match pulled commit"

  # Make another remote commit and test git_safe_pull with dirty local tree
  (
    cd "${clone_dir}"
    echo "remote update 2" > remote_file.txt
    git add remote_file.txt
    git commit -m "remote commit 2" &>/dev/null
    git push origin main &>/dev/null
  )

  echo "uncommitted local work" > local_untracked.txt
  assert_true "git_safe_pull &>/dev/null" "git_safe_pull should stash, pull, and pop"
  assert_true "[[ -f remote_file.txt ]]" "Pulled remote_file.txt should exist"
  assert_true "[[ -f local_untracked.txt ]]" "Stashed local_untracked.txt should be restored"
  rm -f local_untracked.txt
  rm -rf "${bare_dir}" "${clone_dir}"
}

run_test test_git_get_current_branch
run_test test_git_is_clean
run_test test_git_get_root
run_test test_git_status_message
run_test test_git_commit
run_test test_git_branch_exists
run_test test_git_get_commit_hash
run_test test_git_get_commit_message
run_test test_git_push_pull_and_safe_pull

# Cleanup
cd "${original_pwd}"
rm -rf "${test_git_dir}"

exit $(( TESTS_FAILED > 0 ? 1 : 0 ))
