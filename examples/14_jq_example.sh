#!/usr/bin/env zsh
# examples/14_jq_example.sh
# Non-technical guide to JSON query, update, insert, delete, and YAML conversions.

source "$(dirname "$0")/../config/config.sh"
init_config

local json='{"user":{"name":"Alice","roles":["user"],"age":30}}'

# 1. Validate JSON structure
if json_validate "${json}"; then
  echo "JSON structure is valid."
fi

# 2. Query property value
local name=$(json_get_value "${json}" ".user.name")
echo "User Name property: ${name}"

# 3. Modify/update property value
local updated=$(json_set_value "${json}" ".user.age" "35")
echo "Updated JSON: ${updated}"

# 4. Add element to array list
local added=$(json_array_add "${json}" ".user.roles" "\"admin\"")
echo "Added role JSON: ${added}"

# 5. Delete element key from structure
local deleted=$(json_delete_key "${json}" ".user.age")
echo "Deleted age JSON: ${deleted}"

# 6. Convert JSON format to YAML format
echo "YAML Format output:"
json_to_yaml "${json}"
