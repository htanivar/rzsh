# File Navigation & Git Checks Module Reference

- **Source File:** [`functions/03-navigation.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/03-navigation.sh)
- **Description:** Calculates workspace paths relative to active Zsh source trees.

---

## Detailed Usage Examples

### Integration Setup
To use the File Navigation & Git Checks module, ensure the global configurations are initialized, then source the script file:

```zsh
source ./config/config.sh
init_config

source ./functions/03-navigation.sh
```

---

## Function Signatures & Descriptions

### `get_current_directory`

* **Signature:** `get_current_directory`
* **Description:** Outputs the absolute directory of the currently executing/sourced script.

#### Example Code:
```zsh
local current_dir=$(get_current_directory)
```

---
### `dir_up`

* **Signature:** `dir_up <levels>`
* **Description:** Outputs the directory path that is N levels above the current script location.

#### Example Code:
```zsh
local grandparent_dir=$(dir_up 2)
```

---
### `get_absolute_path`

* **Signature:** `get_absolute_path <relative_path>`
* **Description:** Resolves a relative path to its absolute location on the disk, even if the target does not exist.

#### Example Code:
```zsh
local abs_path=$(get_absolute_path "../data/config.json")
```

---
### `get_project_root`

* **Signature:** `get_project_root`
* **Description:** Locates the project root directory by traversing upwards until a .git folder or config file is encountered.

#### Example Code:
```zsh
local root=$(get_project_root)
```

---
### `is_inside_git_repo`

* **Signature:** `is_inside_git_repo`
* **Description:** Returns 0 if the current working directory is inside a Git repository, 1 otherwise.

#### Example Code:
```zsh
is_inside_git_repo && echo "We are in Git!"
```

---
### `normalize_path`

* **Signature:** `normalize_path <raw_path>`
* **Description:** Resolves symlinks, dot-segments, and double slashes in a file path to return a clean canonical absolute path.

#### Example Code:
```zsh
local canonical=$(normalize_path "/etc/../etc/hosts")
```

---
### `ensure_directory_exists`

* **Signature:** `ensure_directory_exists <dir_path>`
* **Description:** Verifies if a directory exists, creating it recursively if missing.

#### Example Code:
```zsh
ensure_directory_exists "/var/log/my_app"
```

---
