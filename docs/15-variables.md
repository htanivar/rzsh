# Configuration Variables Module Reference

- **Source File:** [`functions/15-variables.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/15-variables.sh)
- **Description:** Dynamic configuration variables getter, setter, and unsetter utilities, with specific wrappers for managing repository locations maps.

---

## Detailed Usage Examples

### Integration Setup
To use the Configuration Variables module, you only need to source the configuration script, which automatically imports it:

```zsh
source ./config/config.sh
init_config
```

---

## Function Signatures & Descriptions

### `config_get_var`

* **Signature:** `config_get_var <var_name> [default_value]`
* **Description:** Retrieves the value of a global configuration variable. If the variable is unset or empty, returns the optional default value.

#### Example Code:
```zsh
local log_level=$(config_get_var LOG_LEVEL "INFO")
```

---

### `config_set_var`

* **Signature:** `config_set_var <var_name> <value>`
* **Description:** Sets a global configuration variable dynamically.

#### Example Code:
```zsh
config_set_var LOG_LEVEL "DEBUG"
```

---

### `config_unset_var`

* **Signature:** `config_unset_var <var_name>`
* **Description:** Unsets/removes a global configuration variable.

#### Example Code:
```zsh
config_unset_var JWT_SECRET
```

---

### `config_get_repo_location`

* **Signature:** `config_get_repo_location <repo_name>`
* **Description:** Gets the location of a repository from the `REPO_LOCATIONS` configuration map.

#### Example Code:
```zsh
local loc=$(config_get_repo_location "service1")
```

---

### `config_set_repo_location`

* **Signature:** `config_set_repo_location <repo_name> <location>`
* **Description:** Configures a repository's location path inside `REPO_LOCATIONS`, registering the repository name in the `REPO_NAMES` array if not already present.

#### Example Code:
```zsh
config_set_repo_location "service4" "/home/ubuntu/code/service4"
```

---

### `config_unset_repo_location`

* **Signature:** `config_unset_repo_location <repo_name>`
* **Description:** Unregisters a repository's location from `REPO_LOCATIONS` and removes it from `REPO_NAMES`.

#### Example Code:
```zsh
config_unset_repo_location "service1"
```

---

### `config_list_repos`

* **Signature:** `config_list_repos`
* **Description:** Prints all registered repository names and their mapped locations to stdout.

#### Example Code:
```zsh
config_list_repos
```

---
