# HTTP Client Wrapper Module Reference

- **Source File:** [`functions/06-http.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/06-http.sh)
- **Description:** Robust network calls, status check helpers, and automated retries.

---

## Detailed Usage Examples

### Integration Setup
To use the HTTP Client Wrapper module, you only need to source the configuration script, which automatically imports it:

```zsh
source ./config/config.sh
init_config
```

---

## Function Signatures & Descriptions

### `http_get / http_post / http_put / http_delete`

* **Signature:** `http_get <url> / http_post <url> <body> / http_put <url> <body> / http_delete <url>`
* **Description:** Executes HTTP methods via curl. Appends the HTTP status code as the final line of the returned output.

#### Example Code:
```zsh
local response=$(http_get "https://api.github.com/users/octocat")
```

---
### `is_json_response`

* **Signature:** `is_json_response <http_response>`
* **Description:** Checks if the returned response body is valid JSON.

#### Example Code:
```zsh
is_json_response "${response}"
```

---
### `extract_json_field`

* **Signature:** `extract_json_field <json> <jq_filter>`
* **Description:** Extracts a specific property value using a jq filter path.

#### Example Code:
```zsh
local login=$(extract_json_field "${response}" ".login")
```

---
### `check_status_code`

* **Signature:** `check_status_code <http_response>`
* **Description:** Extracts and prints the trailing HTTP status code from a wrapper response.

#### Example Code:
```zsh
local code=$(check_status_code "${response}")
```

---
### `http_get_body`

* **Signature:** `http_get_body <http_response>`
* **Description:** Extracts and prints the response body from a wrapper response (excluding the status code).

#### Example Code:
```zsh
local body=$(http_get_body "${response}")
```

---
### `http_get_with_retry`

* **Signature:** `http_get_with_retry <url> [retry_count]`
* **Description:** Repeatedly executes an HTTP GET request up to retry_count times (default: 3) until a 2xx status is returned.

#### Example Code:
```zsh
local res=$(http_get_with_retry "https://api.example.com/health" 5)
```

---
