#!/usr/bin/env zsh
# scripts/04-git/compare_branches.sh
# Compare two git branches, output a structured summary, and show contents in separate sections.

# Resolve PROJECT_ROOT dynamically by searching upwards for config/config.sh
if [[ -z "${PROJECT_ROOT:-}" ]]; then
  local current_dir="${0:A:h}"
  while [[ "${current_dir}" != "/" ]]; do
    if [[ -f "${current_dir}/config/config.sh" ]]; then
      export PROJECT_ROOT="${current_dir}"
      break
    fi
    current_dir="${current_dir:h}"
  done
fi

# Source framework config and functions
source "${PROJECT_ROOT}/config/config.sh"
init_config || {
  printf "Error: Failed to initialize framework configuration.\n" >&2
  exit 1
}

# Ensure git functions are sourced
if ! typeset -f git_compare_branches >/dev/null; then
  if [[ -f "${PROJECT_ROOT}/functions/05-git.sh" ]]; then
    source "${PROJECT_ROOT}/functions/05-git.sh"
  fi
fi

git_compare_branches "$@"
exit $?

