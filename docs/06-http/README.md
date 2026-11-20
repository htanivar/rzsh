# HTTP Client Wrapper — Function Index

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../06-http.md) › **06-http/** › [Runnable Example](../../examples/06_http_example.sh) › [Tests](../../tests/06-http.test.sh)

- **Source File:** [`functions/06-http.sh`](../../functions/06-http.sh)
- **Runnable Example:** [`examples/06_http_example.sh`](../../examples/06_http_example.sh)

| Function | Signature | Description |
| :--- | :--- | :--- |
| [`http_set_default_header`](http_set_default_header.md) | `http_set_default_header <name> <value>` | Sets or updates a default HTTP header in HTTP_DEFAULT_HEADERS (case-insensitive key replacement). Passing an empty value unsets the header. |
| [`http_get_default_header`](http_get_default_header.md) | `http_get_default_header <name>` | Retrieves a default HTTP header value from HTTP_DEFAULT_HEADERS (case-insensitive lookup). |
| [`http_unset_default_header`](http_unset_default_header.md) | `http_unset_default_header <name>` | Removes a default HTTP header from HTTP_DEFAULT_HEADERS (case-insensitive lookup). |
| [`http_clear_default_headers`](http_clear_default_headers.md) | `http_clear_default_headers` | Clears all default HTTP headers from HTTP_DEFAULT_HEADERS. |
| [`http_build_headers`](http_build_headers.md) | `http_build_headers [headers...]` | Builds a newline-separated HTTP headers string by merging HTTP_DEFAULT_HEADERS with any extra/override headers passed as arguments. |
| [`http_get`](http_get.md) | `http_get <url> [headers]` | Performs an HTTP GET request using curl. Appends HTTP status code to the last line of the output. |
| [`http_post`](http_post.md) | `http_post <url> <data> [headers]` | Performs an HTTP POST request using curl. Supports passing a JSON string, a path to a .json file, or @file.json. Appends HTTP status code to the last line of the output. |
| [`http_put`](http_put.md) | `http_put <url> <data> [headers]` | Performs an HTTP PUT request using curl. Supports passing a JSON string, a path to a .json file, or @file.json. Appends HTTP status code to the last line of the output. |
| [`http_patch`](http_patch.md) | `http_patch <url> <data> [headers]` | Performs an HTTP PATCH request using curl. Supports passing a JSON string, a path to a .json file, or @file.json. Appends HTTP status code to the last line of the output. |
| [`http_delete`](http_delete.md) | `http_delete <url> [headers]` | Performs an HTTP DELETE request using curl. Appends HTTP status code to the last line of the output. |
| [`check_status_code`](check_status_code.md) | `check_status_code <response>` | Extracts the HTTP status code from the formatted curl response output. |
| [`http_get_body`](http_get_body.md) | `http_get_body <response>` | Extracts the HTTP response body from a raw HTTP response (excluding the trailing status code). |
| [`is_json_response`](is_json_response.md) | `is_json_response <response>` | Checks if the response body (excluding status code) is valid JSON. |
| [`extract_json_field`](extract_json_field.md) | `extract_json_field <json> <field>` | Extracts a specific field from a JSON string using jq. |
| [`download_file`](download_file.md) | `download_file <url> <destination>` | Downloads a file from the specified URL to a local destination file path. |
| [`http_get_with_retry`](http_get_with_retry.md) | `http_get_with_retry <url> [retries=3]` | Performs an HTTP GET request with retries if the status code is not 2xx. |
