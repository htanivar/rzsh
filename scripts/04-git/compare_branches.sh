#!/usr/bin/env zsh
# scripts/04-git/compare_branches.sh
# Compare two git branches, output a structured summary, and show contents in separate sections.
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

# Advise if RZSH_DIR is not set, and fallback to local framework directory
if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${0:A:h:h:h}" >&2
  export RZSH_DIR="${0:A:h:h:h}"
fi

# Source framework config and functions via RZSH_DIR
source "${RZSH_DIR}/config/config.sh"
init_config || {
  printf "Error: Failed to initialize framework configuration.\n" >&2
  exit 1
}

git_compare_branches "$@"
exit $?

