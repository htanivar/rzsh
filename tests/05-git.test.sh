#!/usr/bin/env zsh
# tests/05-git.test.sh
# Breadcrumb: README.md -> GLOSSARY.md -> docs/05-git.md -> examples/05_git_example.sh -> tests/05-git.test.sh
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
  echo "new file" > ask.txt
  local msg
  msg=$(git_status_message)
  assert_true "[[ -n \"${msg}\" ]]" "Status message should not be empty when dirty"
  rm -f ask.txt
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

test_git_compare_commits() {
  local rpt="${test_git_dir}/commit_cmp_report.md"
  assert_true "git_compare_commits -s --diff -o '${rpt}' 'HEAD~1' 'HEAD'" "git_compare_commits should succeed for HEAD~1..HEAD"
  assert_true "[[ -f '${rpt}' ]]" "Commit comparison report file should be created"
  assert_true "grep -q 'Git Commit Comparison Report' '${rpt}'" "Report should contain title"
  assert_true "grep -q 'Unified Patch Diff' '${rpt}'" "Report with --diff should contain patch diff section"
  assert_false "git_compare_commits -s 'nonexistent_ref_xyz' 'HEAD' >/dev/null 2>&1" "Invalid ref should fail"
}

test_git_tag_helpers_and_compare_tags() {
  git tag v1.0.0 HEAD~1
  git tag v1.1.0 HEAD
  assert_true "git_tag_exists 'v1.0.0'" "Tag v1.0.0 should exist"
  assert_false "git_tag_exists 'v9.9.9'" "Tag v9.9.9 should not exist"

  local tags_list
  tags_list=$(git_list_tags "v1.*")
  assert_true "[[ \"${tags_list}\" == *'v1.1.0'* ]]" "git_list_tags should list v1.1.0"

  local rpt="${test_git_dir}/tag_cmp_report.md"
  assert_true "git_compare_tags -s -o '${rpt}' 'v1.0.0' 'v1.1.0'" "git_compare_tags should succeed for v1.0.0..v1.1.0"
  assert_true "[[ -f '${rpt}' ]]" "Tag comparison report should be created"
  assert_true "grep -q 'Git Tag Comparison Report' '${rpt}'" "Tag report should contain title"
  assert_true "grep -q '\`\`\`diff' '${rpt}'" "Tag report should contain color-coded diff block"

  # Auto-detect latest 2 tags
  local auto_rpt="${test_git_dir}/tag_auto_report.md"
  assert_true "git_compare_tags -s -o '${auto_rpt}'" "git_compare_tags with 0 args should auto-detect latest 2 tags"
  assert_true "[[ -f '${auto_rpt}' ]]" "Auto tag report should be created"
  assert_false "git_compare_tags -s 'missing_tag' 'v1.1.0' >/dev/null 2>&1" "Missing tag should fail"
}

test_git_compare_releases() {
  git branch release/1.0.0 HEAD~1
  git branch release/1.1.0 HEAD
  local rpt="${test_git_dir}/release_cmp_report.md"
  assert_true "git_compare_releases -s -o '${rpt}' 'release/1.0.0' 'release/1.1.0'" "git_compare_releases should succeed"
  assert_true "[[ -f '${rpt}' ]]" "Release comparison report should be created"
  assert_true "grep -q 'Git Release Comparison Report' '${rpt}'" "Release report should contain title"
  assert_true "grep -q 'Commit & Scope Summary' '${rpt}'" "Release report should contain Commit & Scope Summary"
}

test_git_compare_content_and_worktree() {
  echo "extra content line" >> file.txt
  local wt_rpt="${test_git_dir}/worktree_cmp_report.md"
  assert_true "git_compare_working_tree -s -o '${wt_rpt}'" "git_compare_working_tree should succeed"
  assert_true "[[ -f '${wt_rpt}' ]]" "Worktree report should be created"
  assert_true "grep -q 'file.txt' '${wt_rpt}'" "Worktree report should mention modified file.txt"

  git add file.txt
  local staged_rpt="${test_git_dir}/staged_cmp_report.md"
  assert_true "git_compare_working_tree --staged -s -o '${staged_rpt}'" "git_compare_working_tree --staged should succeed"
  assert_true "grep -q 'Staged Index' '${staged_rpt}'" "Staged report should mention Staged Index"
  git reset HEAD file.txt >/dev/null 2>&1
  git checkout -- file.txt

  local content_rpt="${test_git_dir}/content_cmp_report.md"
  assert_true "git_compare_content -s -p file.txt -o '${content_rpt}' 'HEAD~1' 'HEAD'" "git_compare_content with --path should succeed"
  assert_true "grep -q 'Git Content Comparison Report' '${content_rpt}'" "Content report should contain title"
  assert_true "grep -q 'file.txt' '${content_rpt}'" "Content report should contain file.txt"
}

test_git_compare_dispatcher_and_script() {
  local types_out
  types_out=$(git_compare --list-types)
  assert_true "[[ \"${types_out}\" == *'tag'* && \"${types_out}\" == *'release'* && \"${types_out}\" == *'content'* ]]" "git_compare --list-types should list all types"

  local rpt="${test_git_dir}/dispatcher_tag.md"
  assert_true "git_compare --type tag -s -o '${rpt}' 'v1.0.0' 'v1.1.0'" "git_compare --type tag should succeed"
  assert_true "[[ -f '${rpt}' ]]" "Dispatcher tag report should be created"

  local cli_rpt="${test_git_dir}/cli_release.md"
  assert_true "zsh '${RZSH_DIR}/scripts/04-git/compare_git.sh' --type release -s -o '${cli_rpt}' 'release/1.0.0' 'release/1.1.0'" "compare_git.sh CLI should succeed"
  assert_true "[[ -f '${cli_rpt}' ]]" "CLI release report should be created"

  assert_false "git_compare --type invalid_type >/dev/null 2>&1" "Invalid comparison type should fail"
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
run_test test_git_compare_commits
run_test test_git_tag_helpers_and_compare_tags
run_test test_git_compare_releases
run_test test_git_compare_content_and_worktree
run_test test_git_compare_dispatcher_and_script

# Cleanup
cd "${original_pwd}"
rm -rf "${test_git_dir}"

exit $(( TESTS_FAILED > 0 ? 1 : 0 ))
