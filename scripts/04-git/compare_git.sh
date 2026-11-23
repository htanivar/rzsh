#!/usr/bin/env zsh
# scripts/04-git/compare_git.sh
# Comprehensive Git comparison CLI supporting branch, commit, tag, release, content, worktree, and three-way reports.
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${0:A:h:h:h}" >&2
  export RZSH_DIR="${0:A:h:h:h}"
fi

source "${RZSH_DIR}/config/config.sh"
init_config || {
  printf "Error: Failed to initialize framework configuration.\n" >&2
  exit 1
}

if [[ $# -eq 0 ]]; then
  is_inside_git_repo || error_exit "Not inside a Git repository."
  selected_type=$(select_option "Select Git comparison type:" "branch" "commit" "tag" "release" "content" "worktree" "three-way") || exit 1
  src_ref=$(read_input "Enter source/base ref (leave blank for auto-detect if supported):")
  tgt_ref=$(read_input "Enter target ref (leave blank for default/HEAD):")

  args=( --type "${selected_type}" )
  [[ -n "${src_ref}" ]] && args+=( "${src_ref}" )
  [[ -n "${tgt_ref}" ]] && args+=( "${tgt_ref}" )

  git_compare "${args[@]}"
  exit $?
fi

git_compare "$@"
exit $?
