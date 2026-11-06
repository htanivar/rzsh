# HTTP Client Wrapper Module Reference

- **Source File:** [`functions/06-http.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/06-http.sh)
- **Example Script:** [`examples/06_http_example.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/examples/06_http_example.sh)
- **Description:** Robust network calls, flexible JSON payload handling (`.json` files, templates, or strings), status check helpers, and automated retries.

---

## Integration Setup

To use the HTTP Client Wrapper module, source the configuration script via `RZSH_DIR`, which automatically imports all HTTP and JSON functions:

```zsh
#!/usr/bin/env zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

---

## All Ways to Send a JSON Payload (`POST`, `PUT`, `PATCH`)

Typing complex JSON as an inline shell string can be error-prone because of quotes and escaping. `http_post`, `http_put`, and `http_patch` support **5 convenient ways** to pass your payload:

### Way 1 (Recommended): Pass a `.json` File Path Directly
Save your request body in a normal `.json` file and pass its path as the second argument. The framework automatically reads the file and sends its contents:

```zsh
# 1. Create or point to your .json file
cat << 'EOF' > ./user_payload.json
{
  "name": "Alice",
  "email": "alice@example.com",
  "role": "developer"
}
EOF

# 2. Pass the .json file path directly!
response=$(http_post "https://httpbin.org/post" "./user_payload.json" "Content-Type: application/json")
```

### Way 2: Use `curl`-Style `@file.json` Syntax
If you are used to `curl -d @file.json`, prefixing the file path with `@` is also supported:

```zsh
response=$(http_post "https://httpbin.org/post" "@./user_payload.json" "Content-Type: application/json")
```

### Way 3: Load a `.json` Template File and Override Specific Fields
Keep a reusable template `.json` file on disk, read it with `file_read`, customize 1 or 2 fields dynamically with `json_set_value`, and send it:

```zsh
# Load base JSON from file
payload=$(file_read "./user_payload.json")

# Dynamically update fields before sending
payload=$(json_set_value "${payload}" ".role" "admin")
payload=$(json_set_value "${payload}" ".environment" "production")

response=$(http_put "https://httpbin.org/put" "${payload}" "Content-Type: application/json")
```

### Way 4: Build a Payload Dynamically Using `json_set_value`
Build JSON step-by-step from shell variables without writing raw JSON brackets or quotes:

```zsh
payload='{}'
payload=$(json_set_value "${payload}" ".service" "billing-api")
payload=$(json_set_value "${payload}" ".replicas" "3")
payload=$(json_set_value "${payload}" ".tags" '["v1","production"]')

response=$(http_post "https://httpbin.org/post" "${payload}" "Content-Type: application/json")
```

### Way 5: Simple Inline JSON String
For tiny one-field updates (like `PATCH`), pass a short single-quoted JSON string:

```zsh
response=$(http_patch "https://httpbin.org/patch" '{"status":"active"}' "Content-Type: application/json")
```

---

## Passing Custom Headers (e.g., Authorization Bearer Token)

Pass one or more headers as the optional final argument (separated by newlines if sending multiple headers):

```zsh
headers=$'Content-Type: application/json\nAuthorization: Bearer my-secret-token'
response=$(http_post "https://httpbin.org/post" "./user_payload.json" "${headers}")
```

---

## Function Signatures & Descriptions

### `http_get`
* **Signature:** `http_get <url> [headers]`
* **Description:** Performs an HTTP GET request via `curl` and appends the HTTP status code on the last line.
```zsh
response=$(http_get "https://api.github.com/users/octocat")
```

### `http_post / http_put / http_patch`
* **Signature:** `http_post <url> <json_file_or_string> [headers]`
* **Description:** Sends an HTTP `POST`, `PUT`, or `PATCH` request. Accepts a `.json` file path, `@file.json`, or raw JSON string as the second argument.
```zsh
response=$(http_post "https://httpbin.org/post" "./payload.json" "Content-Type: application/json")
```

### `http_delete`
* **Signature:** `http_delete <url> [headers]`
* **Description:** Performs an HTTP DELETE request.
```zsh
response=$(http_delete "https://httpbin.org/delete")
```

### `check_status_code`
* **Signature:** `check_status_code <http_response>`
* **Description:** Extracts the 3-digit HTTP status code (e.g., `200`, `201`, `404`) from the response.
```zsh
code=$(check_status_code "${response}")
```

### `http_get_body`
* **Signature:** `http_get_body <http_response>`
* **Description:** Extracts the response body (excluding the trailing status code).
```zsh
body=$(http_get_body "${response}")
```

### `is_json_response`
* **Signature:** `is_json_response <http_response>`
* **Description:** Returns `0` (true) if the response body is valid JSON.
```zsh
if is_json_response "${response}"; then
  echo "Valid JSON received!"
fi
```

### `extract_json_field`
* **Signature:** `extract_json_field <json_body> <jq_filter>`
* **Description:** Extracts a specific field from a JSON string using a `jq` filter path.
```zsh
body=$(http_get_body "${response}")
user_name=$(extract_json_field "${body}" ".json.name")
```

### `download_file`
* **Signature:** `download_file <url> <destination_path>`
* **Description:** Downloads a remote file directly to a local file path.
```zsh
download_file "https://example.com/report.pdf" "./logs/report.pdf"
```

### `http_get_with_retry`
* **Signature:** `http_get_with_retry <url> [retry_count]`
* **Description:** Repeatedly executes an HTTP GET request up to `retry_count` times (default: `3`) until a `2xx` status code is returned.
```zsh
res=$(http_get_with_retry "https://api.example.com/health" 5)
```
