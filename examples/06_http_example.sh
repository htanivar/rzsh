#!/usr/bin/env zsh
# examples/06_http_example.sh
# Non-technical guide to performing HTTP GET, POST, PATCH, PUT & DELETE calls and building/parsing JSON payloads using JQ module.

source "$(dirname "$0")/../config/config.sh"
init_config

echo "=== HTTP API Operations Demo ==="

# 1. HTTP GET Request
echo "\n1. Sending HTTP GET..."
local get_res=$(http_get "https://httpbin.org/get")
local get_code=$(check_status_code "${get_res}")
local get_body=$(http_get_body "${get_res}")

echo "GET Status Code: ${get_code}"
if json_validate "${get_body}"; then
  local ua=$(json_get_value "${get_body}" ".headers[\"User-Agent\"]")
  echo "GET Response Headers User-Agent: ${ua}"
fi

# 2. HTTP POST Request (Building payload dynamically with json_set_value)
echo "\n2. Sending HTTP POST..."
local post_payload='{}'
post_payload=$(json_set_value "${post_payload}" ".name" "Alice")
post_payload=$(json_set_value "${post_payload}" ".role" "admin")
echo "Constructed POST Payload: ${post_payload}"

local post_res=$(http_post "https://httpbin.org/post" "${post_payload}" "Content-Type: application/json")
local post_code=$(check_status_code "${post_res}")
local post_body=$(http_get_body "${post_res}")

echo "POST Status Code: ${post_code}"
if json_validate "${post_body}"; then
  local received_name=$(json_get_value "${post_body}" ".json.name")
  echo "POST Server Echoed Name: ${received_name}"
fi

# 3. HTTP PUT Request (Building payload dynamically with json_set_value)
echo "\n3. Sending HTTP PUT..."
local put_payload='{}'
put_payload=$(json_set_value "${put_payload}" ".name" "Alice")
put_payload=$(json_set_value "${put_payload}" ".role" "super-admin")
echo "Constructed PUT Payload: ${put_payload}"

local put_res=$(http_put "https://httpbin.org/put" "${put_payload}" "Content-Type: application/json")
local put_code=$(check_status_code "${put_res}")
local put_body=$(http_get_body "${put_res}")

echo "PUT Status Code: ${put_code}"
if json_validate "${put_body}"; then
  local put_role=$(json_get_value "${put_body}" ".json.role")
  echo "PUT Server Echoed Role: ${put_role}"
fi

# 4. HTTP PATCH Request (Building payload dynamically with json_set_value)
echo "\n4. Sending HTTP PATCH..."
local patch_payload='{}'
patch_payload=$(json_set_value "${patch_payload}" ".status" "active")
echo "Constructed PATCH Payload: ${patch_payload}"

local patch_res=$(http_patch "https://httpbin.org/patch" "${patch_payload}" "Content-Type: application/json")
local patch_code=$(check_status_code "${patch_res}")
local patch_body=$(http_get_body "${patch_res}")

echo "PATCH Status Code: ${patch_code}"
if json_validate "${patch_body}"; then
  local patch_status=$(json_get_value "${patch_body}" ".json.status")
  echo "PATCH Server Echoed Status: ${patch_status}"
fi

# 5. HTTP DELETE Request
echo "\n5. Sending HTTP DELETE..."
local delete_res=$(http_delete "https://httpbin.org/delete" "Content-Type: application/json")
local delete_code=$(check_status_code "${delete_res}")
echo "DELETE Status Code: ${delete_code}"

# 6. HTTP GET with Auto-Retries
echo "\n6. Sending HTTP GET with Retries (max 3 times)..."
local retry_res=$(http_get_with_retry "https://httpbin.org/status/200" 3)
local retry_code=$(check_status_code "${retry_res}")
echo "Retry Status Code: ${retry_code}"
