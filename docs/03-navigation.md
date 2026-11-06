# File Navigation & Git Checks Module Reference

- **Source File:** [`functions/03-navigation.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/03-navigation.sh)
- **Description:** Calculates workspace paths relative to active Zsh source trees.

---

## Detailed Usage Examples

### Integration Setup
To use the File Navigation & Git Checks module, source the configuration script via `RZSH_DIR`, which automatically imports it:

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

---

## Module Variables (Keys)

| Variable Key | Description |
| :--- | :--- |
| `RZSH_DIR` | Root directory of the `rzsh` framework. |
| `PROJECT_ROOT` | Active project root directory used by `to_project_root` and `get_project_root`. |

---

## Function Signatures & Descriptions

### `current_directory` / `get_current_directory`

* **Signature:** `current_directory` / `get_current_directory`
* **Description:** Outputs the absolute path of the current working directory.

#### Example Code:
```zsh
local current_dir=$(get_current_directory)
```

---
### `dir_up`

* **Signature:** `dir_up [levels=1]`
* **Description:** Outputs the directory path that is N levels above the current working directory.

#### Example Code:
```zsh
local grandparent_dir=$(dir_up 2)
```

---
### `absolute_path` / `get_absolute_path`

* **Signature:** `absolute_path [target_path="."]` / `get_absolute_path [target_path="."]`
* **Description:** Resolves a relative path or symlink to its canonical absolute location on disk.

#### Example Code:
```zsh
local abs_path=$(get_absolute_path "../data/config.json")
```

---
### `to_project_root`

* **Signature:** `to_project_root`
* **Description:** Changes the current working directory (`cd`) to `PROJECT_ROOT`.

#### Example Code:
```zsh
to_project_root
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
### `change_directory`

* **Signature:** `change_directory <dir_path>`
* **Description:** Changes the current working directory to the specified path.

#### Example Code:
```zsh
change_directory "/tmp"
```

---
