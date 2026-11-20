# HTTP Client Wrapper Module Reference

**Navigation:** [README](../README.md) › [GLOSSARY](../GLOSSARY.md) › **06-http.md** › [Example](../examples/06_http_example.sh) › [Tests](../tests/06-http.test.sh)

- **Source File:** [`functions/06-http.sh`](../functions/06-http.sh)
- **Example Script:** [`examples/06_http_example.sh`](../examples/06_http_example.sh)
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

---

## Default HTTP Headers & Header Builder

`init_config` initializes `HTTP_DEFAULT_HEADERS` from `HTTP_CONTENT_TYPE`, `HTTP_ACCEPT`, `HTTP_AUTH_TOKEN`, `HTTP_VAULT_TOKEN`, and `HTTP_VAULT_REQUEST`. All `http_*` functions automatically merge `HTTP_DEFAULT_HEADERS` with any per-request headers you pass (per-request headers override matching default keys case-insensitively).

### `http_build_headers`
* **Signature:** `http_build_headers [headers...]`
* **Description:** Builds a newline-separated `"Key: Value"` header string by merging `HTTP_DEFAULT_HEADERS` with any extra or override headers.
```zsh
headers=$(http_build_headers "X-Request-Id: req-42" "Accept: text/plain")
```

### `http_set_default_header`
* **Signature:** `http_set_default_header <name> <value>`
* **Description:** Sets or updates a default HTTP header in `HTTP_DEFAULT_HEADERS` (case-insensitive key replacement). Passing an empty value unsets the header.
```zsh
http_set_default_header "Authorization" "Bearer my-secret-token"
http_set_default_header "X-Vault-Request" "true"
```

### `http_get_default_header`
* **Signature:** `http_get_default_header <name>`
* **Description:** Retrieves a default HTTP header value from `HTTP_DEFAULT_HEADERS` (case-insensitive lookup).
```zsh
ct=$(http_get_default_header "Content-Type")
```

### `http_unset_default_header`
* **Signature:** `http_unset_default_header <name>`
* **Description:** Removes a default HTTP header from `HTTP_DEFAULT_HEADERS` (case-insensitive lookup).
```zsh
http_unset_default_header "X-Vault-Request"
```

### `http_clear_default_headers`
* **Signature:** `http_clear_default_headers`
* **Description:** Clears all entries from `HTTP_DEFAULT_HEADERS`.
```zsh
http_clear_default_headers
```

---

## Per-Function Copy-Paste Reference

Browse dedicated per-function pages with all flags and copy-paste variations in [`docs/06-http/`](06-http/README.md), or run [`examples/06_http_example.sh`](../examples/06_http_example.sh).

| Function | Per-Function Docs & Flags | Runnable Example |
| :--- | :--- | :--- |
| `http_set_default_header` | [Docs & Examples](06-http/http_set_default_header.md) | [`06_http_example.sh`](../examples/06_http_example.sh) |
| `http_get_default_header` | [Docs & Examples](06-http/http_get_default_header.md) | [`06_http_example.sh`](../examples/06_http_example.sh) |
| `http_unset_default_header` | [Docs & Examples](06-http/http_unset_default_header.md) | [`06_http_example.sh`](../examples/06_http_example.sh) |
| `http_clear_default_headers` | [Docs & Examples](06-http/http_clear_default_headers.md) | [`06_http_example.sh`](../examples/06_http_example.sh) |
| `http_build_headers` | [Docs & Examples](06-http/http_build_headers.md) | [`06_http_example.sh`](../examples/06_http_example.sh) |
| `http_get` | [Docs & Examples](06-http/http_get.md) | [`06_http_example.sh`](../examples/06_http_example.sh) |
| `http_post` | [Docs & Examples](06-http/http_post.md) | [`06_http_example.sh`](../examples/06_http_example.sh) |
| `http_put` | [Docs & Examples](06-http/http_put.md) | [`06_http_example.sh`](../examples/06_http_example.sh) |
| `http_patch` | [Docs & Examples](06-http/http_patch.md) | [`06_http_example.sh`](../examples/06_http_example.sh) |
| `http_delete` | [Docs & Examples](06-http/http_delete.md) | [`06_http_example.sh`](../examples/06_http_example.sh) |
| `check_status_code` | [Docs & Examples](06-http/check_status_code.md) | [`06_http_example.sh`](../examples/06_http_example.sh) |
| `http_get_body` | [Docs & Examples](06-http/http_get_body.md) | [`06_http_example.sh`](../examples/06_http_example.sh) |
| `is_json_response` | [Docs & Examples](06-http/is_json_response.md) | [`06_http_example.sh`](../examples/06_http_example.sh) |
| `extract_json_field` | [Docs & Examples](06-http/extract_json_field.md) | [`06_http_example.sh`](../examples/06_http_example.sh) |
| `download_file` | [Docs & Examples](06-http/download_file.md) | [`06_http_example.sh`](../examples/06_http_example.sh) |
| `http_get_with_retry` | [Docs & Examples](06-http/http_get_with_retry.md) | [`06_http_example.sh`](../examples/06_http_example.sh) |