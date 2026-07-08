# JSON Parsing Module Reference

- **Source File:** [`functions/12-json.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/12-json.sh)
- **Description:** Jq query wrappers, keys extraction, merge objects, arrays, and YAML conversion.

---

## Detailed Usage Examples

### Integration Setup
To use the JSON Parsing module, ensure the global configurations are initialized, then source the script file:

```zsh
source ./config/config.sh
init_config

source ./functions/12-json.sh
```

---

## Function Signatures & Descriptions

### `json_parse / json_validate`

* **Signature:** `json_parse <json> / json_validate <json>`
* **Description:** Pretty prints a JSON structure, or validates formatting.

#### Example Code:
```zsh
json_validate "invalid" || echo "Bad JSON"
```

---
### `json_get_value`

* **Signature:** `json_get_value <json> <jq_path>`
* **Description:** Queries property using jq filter. Declares local json_path to prevent Zsh path binding array conflicts.

#### Example Code:
```zsh
local name=$(json_get_value "${json}" ".user.name")
```

---
### `json_set_value`

* **Signature:** `json_set_value <json> <jq_path> <value>`
* **Description:** Modifies/adds property value at jq path.

#### Example Code:
```zsh
local updated=$(json_set_value "${json}" ".user.age" "25")
```

---
### `json_delete_key`

* **Signature:** `json_delete_key <json> <jq_path>`
* **Description:** Deletes key at path.

#### Example Code:
```zsh
local cleaned=$(json_delete_key "${json}" ".user.password")
```

---
### `json_get_keys`

* **Signature:** `json_get_keys <json> [jq_path]`
* **Description:** Lists keys inside the specified JSON object path.

#### Example Code:
```zsh
local keys=$(json_get_keys "${json}" ".user")
```

---
### `json_merge`

* **Signature:** `json_merge <json1> <json2>`
* **Description:** Deep merges two JSON documents together.

#### Example Code:
```zsh
local combined=$(json_merge "${j1}" "${j2}")
```

---
### `json_to_yaml`

* **Signature:** `json_to_yaml <json>`
* **Description:** Converts a JSON document to a formatted YAML string.

#### Example Code:
```zsh
local yaml=$(json_to_yaml "${json}")
```

---
### `json_array_add / json_array_remove`

* **Signature:** `json_array_add <json> <jq_path> <item> / json_array_remove <json> <jq_path> <index>`
* **Description:** Appends item to array, or deletes array element at index.

#### Example Code:
```zsh
local res=$(json_array_add "${json}" ".tags" "\"admin\"")
```

---
### `json_compact`

* **Signature:** `json_compact <json>`
* **Description:** Removes all unnecessary whitespace and compacts JSON string to a single line.

#### Example Code:
```zsh
local flat=$(json_compact "${pretty_json}")
```

---
