# HTTP Client Wrapper Module Reference

- **Source File:** [`functions/06-curl.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/06-curl.sh)
- **Description:** Robust network calls, status check helpers, and automated retries.

---

## Detailed Usage Examples

### Integration Setup
To use the HTTP Client Wrapper module, ensure the global configurations are initialized, then source the script file:

```zsh
source ./config/config.sh
init_config

source ./functions/06-curl.sh
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
### `http_get_with_retry`

* **Signature:** `http_get_with_retry <url> [retry_count]`
* **Description:** Repeatedly executes an HTTP GET request up to retry_count times (default: 3) until a 2xx status is returned.

#### Example Code:
```zsh
local res=$(http_get_with_retry "https://api.example.com/health" 5)
```

---
