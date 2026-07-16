#!/usr/bin/env zsh
# examples/15_variables_example.sh
# Guide to getting, setting, and unsetting global configuration variables and repository locations.

source "$(dirname "$0")/../config/config.sh"
init_config

echo "=== Configuration Variables Example ==="

# 1. Get a global variable with dynamic fallback
local level=$(config_get_var LOG_LEVEL "INFO")
echo "Current LOG_LEVEL: ${level}"

# 2. Set/Override a global variable
config_set_var MY_NEW_VAR "Antigravity Active"
local my_var=$(config_get_var MY_NEW_VAR)
echo "MY_NEW_VAR value: ${my_var}"

# 3. Unset a global variable
config_unset_var MY_NEW_VAR
local my_var_after=$(config_get_var MY_NEW_VAR "not found")
echo "MY_NEW_VAR after unset: ${my_var_after}"

echo ""
echo "=== Repository Locations Example ==="

# 4. List registered repositories
echo "Initial Repositories:"
config_list_repos

# 5. Get location of an existing repo
local loc=$(config_get_repo_location "service1")
echo "Location of service1: ${loc}"

# 6. Set location of a new repository
config_set_repo_location "service4" "/home/ubuntu/code/service4"
echo "Location of service4: $(config_get_repo_location "service4")"

# 7. List repositories after adding a new one
echo ""
echo "Repositories after adding service4:"
config_list_repos

# 8. Unset/Remove a repository
config_unset_repo_location "service2"
echo ""
echo "Repositories after removing service2:"
config_list_repos
