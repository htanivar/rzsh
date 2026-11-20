# JSON Parsing & JQ — Function Index

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../14-jq.md) › **14-jq/** › [Runnable Example](../../examples/14_jq_example.sh) › [Tests](../../tests/14-jq.test.sh)

- **Source File:** [`functions/14-jq.sh`](../../functions/14-jq.sh)
- **Runnable Example:** [`examples/14_jq_example.sh`](../../examples/14_jq_example.sh)

| Function | Signature | Description |
| :--- | :--- | :--- |
| [`json_parse`](json_parse.md) | `json_parse <json>` | Parses and prints the structured representation of a JSON string. |
| [`json_get_value`](json_get_value.md) | `json_get_value <json> <path>` | Gets the value at the specified JSON path using jq. |
| [`json_set_value`](json_set_value.md) | `json_set_value <json> <path> <value>` | Modifies/adds a value at the specified JSON path. |
| [`json_delete_key`](json_delete_key.md) | `json_delete_key <json> <path>` | Deletes a key/field at the specified JSON path. |
| [`json_get_keys`](json_get_keys.md) | `json_get_keys <json> [path="."]` | Gets all keys at the specified JSON path. |
| [`json_merge`](json_merge.md) | `json_merge <json1> <json2>` | Merges two JSON objects together. |
| [`json_to_yaml`](json_to_yaml.md) | `json_to_yaml <json>` | Converts a JSON string to YAML format. |
| [`json_validate`](json_validate.md) | `json_validate <json>` | Validates if a string is a syntactically correct JSON document. |
| [`json_beautify`](json_beautify.md) | `json_beautify <json>` | Formats a JSON string with pretty spacing/indentation. |
| [`json_escape`](json_escape.md) | `json_escape <json>` | Escapes a JSON string so it can be safely used in a string field. |
| [`json_array_add`](json_array_add.md) | `json_array_add <json> <path> <item>` | Appends an item to a JSON array at the specified path. |
| [`json_array_remove`](json_array_remove.md) | `json_array_remove <json> <path> <index>` | Removes an item from a JSON array by its index. |
| [`json_extract_path`](json_extract_path.md) | `json_extract_path <json> <path>` | Alias to json_get_value. Retrieves a value from a JSON path. |
| [`json_compact`](json_compact.md) | `json_compact <json>` | Compacts a JSON string, removing all non-essential formatting whitespace. |
