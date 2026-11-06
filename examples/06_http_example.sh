#!/usr/bin/env zsh
# examples/06_http_example.sh
# Non-technical guide to performing HTTP GET, POST, PUT, PATCH & DELETE calls
# and all the different ways you can pass JSON payloads (especially using .json files).
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

source "$(dirname "$0")/../config/config.sh"
init_config

echo "=== HTTP API Operations & JSON Payload Guide ==="

# Offline fallback so this example runs even without internet access
if ! command curl -s -m 2 -o /dev/null "https://httpbin.org/get" 2>/dev/null; then
  curl() {
    local arg method="GET" data="{}" prev=""
    for arg in "$@"; do
      if [[ "${prev}" == "-X" ]]; then
        method="${arg}"
      elif [[ "${prev}" == "-d" ]]; then
        data="${arg}"
      fi
      prev="${arg}"
    done
    case "${method}" in
      GET)    printf '{"headers":{"User-Agent":"rzsh-http-client/1.0"}}\n200' ;;
      POST)   printf '{"json":%s}\n200' "${data}" ;;
      PUT)    printf '{"json":%s}\n200' "${data}" ;;
      PATCH)  printf '{"json":%s}\n200' "${data}" ;;
      DELETE) printf '{"deleted":true}\n200' ;;
    esac
  }
fi

# Create a temporary directory for our sample .json payload files
mkdir -p "${PROJECT_ROOT}/logs"
payload_file="${PROJECT_ROOT}/logs/sample_user_payload.json"
register_temp_file "${payload_file}"

# ------------------------------------------------------------------------------
# 1. HTTP GET Request
# ------------------------------------------------------------------------------
echo "\n1. Sending HTTP GET..."
get_res=$(http_get "https://httpbin.org/get")
get_code=$(check_status_code "${get_res}")
get_body=$(http_get_body "${get_res}")

echo "GET Status Code: ${get_code}"
if json_validate "${get_body}"; then
  ua=$(json_get_value "${get_body}" '.headers["User-Agent"]')
  echo "GET Response Headers User-Agent: ${ua}"
fi

# ------------------------------------------------------------------------------
# 2. WAY 1 (Recommended): Send a .json File Directly as Input
#    Write your JSON cleanly in a .json file (no messy quote escaping!) and pass
#    the file path directly to http_post, http_put, or http_patch.
# ------------------------------------------------------------------------------
echo "\n2. [Way 1 - Recommended] Sending HTTP POST using a .json file path..."

cat << 'EOF' > "${payload_file}"
{
  "name": "Alice",
  "email": "alice@example.com",
  "role": "developer",
  "active": true
}
EOF

post_res=$(http_post "https://httpbin.org/post" "${payload_file}" "Content-Type: application/json")
post_code=$(check_status_code "${post_res}")
post_body=$(http_get_body "${post_res}")

echo "POST (.json file) Status Code: ${post_code}"
if json_validate "${post_body}"; then
  echo "Server Received Name:  $(json_get_value "${post_body}" ".json.name")"
  echo "Server Received Email: $(json_get_value "${post_body}" ".json.email")"
fi

# ------------------------------------------------------------------------------
# 3. WAY 2: Send a .json File Using curl's @file.json Syntax
# ------------------------------------------------------------------------------
echo "\n3. [Way 2] Sending HTTP POST using @file.json syntax..."
at_res=$(http_post "https://httpbin.org/post" "@${payload_file}" "Content-Type: application/json")
echo "POST (@file.json) Status Code: $(check_status_code "${at_res}")"

# ------------------------------------------------------------------------------
# 4. WAY 3: Load a .json Template File, Update Fields Dynamically, and Send
#    Great when you have a base payload.json file and only want to change 1 or 2
#    values (like an environment name, timestamp, or username) before sending.
# ------------------------------------------------------------------------------
echo "\n4. [Way 3] Loading .json template file, updating values, and sending HTTP PUT..."
template_json=$(file_read "${payload_file}")
template_json=$(json_set_value "${template_json}" ".role" "super-admin")
template_json=$(json_set_value "${template_json}" ".environment" "production")

put_res=$(http_put "https://httpbin.org/put" "${template_json}" "Content-Type: application/json")
put_code=$(check_status_code "${put_res}")
put_body=$(http_get_body "${put_res}")

echo "PUT (Template + Dynamic Update) Status Code: ${put_code}"
if json_validate "${put_body}"; then
  echo "Updated Role Sent:        $(json_get_value "${put_body}" ".json.role")"
  echo "Updated Environment Sent: $(json_get_value "${put_body}" ".json.environment")"
fi

# ------------------------------------------------------------------------------
# 5. WAY 4: Build Payload Dynamically from Scratch with json_set_value
#    Helpful when constructing JSON from shell variables without a file.
# ------------------------------------------------------------------------------
echo "\n5. [Way 4] Building payload dynamically with json_set_value & json_array_add..."
dynamic_payload='{}'
dynamic_payload=$(json_set_value "${dynamic_payload}" ".service" "payment-api")
dynamic_payload=$(json_set_value "${dynamic_payload}" ".replicas" "3")
dynamic_payload=$(json_set_value "${dynamic_payload}" ".tags" '["v1","stable"]')
dynamic_payload=$(json_array_add "${dynamic_payload}" ".tags" '"production"')

dyn_res=$(http_post "https://httpbin.org/post" "${dynamic_payload}" "Content-Type: application/json")
echo "POST (Dynamic Builder) Status Code: $(check_status_code "${dyn_res}")"

# ------------------------------------------------------------------------------
# 6. WAY 5: Simple Inline JSON String (Best for tiny 1-field updates)
# ------------------------------------------------------------------------------
echo "\n6. [Way 5] Sending HTTP PATCH with a short inline JSON string..."
patch_res=$(http_patch "https://httpbin.org/patch" '{"status":"active"}' "Content-Type: application/json")
patch_code=$(check_status_code "${patch_res}")
patch_body=$(http_get_body "${patch_res}")

echo "PATCH Status Code: ${patch_code}"
if json_validate "${patch_body}"; then
  echo "PATCH Server Echoed Status: $(json_get_value "${patch_body}" ".json.status")"
fi

# ------------------------------------------------------------------------------
# 7. HTTP DELETE & HTTP GET with Auto-Retries
# ------------------------------------------------------------------------------
echo "\n7. Sending HTTP DELETE..."
delete_res=$(http_delete "https://httpbin.org/delete" "Content-Type: application/json")
echo "DELETE Status Code: $(check_status_code "${delete_res}")"

echo "\n8. Sending HTTP GET with Retries (max 3 times)..."
retry_res=$(http_get_with_retry "https://httpbin.org/status/200" 3)
echo "Retry Status Code: $(check_status_code "${retry_res}")"

# Clean up temporary payload file
cleanup_temp_files
