#!/usr/bin/env zsh

# 1. Load the framework via RZSH_DIR (this imports all helper functions automatically)
source "${RZSH_DIR}/config/config.sh"
init_config
init_logging

local current_dir=$(get_current_directory)
log_info $current_dir
local branch=$(git_get_current_branch)
log_info $branch

change_directory $RDOCKER_DIR
local branch=$(git_get_current_branch)
log_info $branch


# List and iterate over release branches
local -a branches
branches=( ${(f)"$(git_list_branches 'release/*')"} )
validate_in_list "release/2.2.0" ${branches}

local doc_dir=$(get_current_directory)
log_info $doc_dir

change_directory $current_dir