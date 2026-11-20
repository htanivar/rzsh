# File Navigation & Git Checks Module Reference

**Navigation:** [README](../README.md) › [GLOSSARY](../GLOSSARY.md) › **03-navigation.md** › [Example](../examples/03_navigation_example.sh) › [Tests](../tests/03-navigation.test.sh)

- **Source File:** [`functions/03-navigation.sh`](../functions/03-navigation.sh)
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
! is_inside_git_repo && echo "We are NOT in Git!"
--
is_inside_git_repo && in_git=true || in_git=false
--
# later
if [ "$in_git" = true ]; then
    echo "inside repo"
else
    echo "not inside repo"
fi
--
! is_inside_git_repo
status=$?
echo "negative status: $status"   # 0 means NOT in repo
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

---

## Per-Function Copy-Paste Reference

Browse dedicated per-function pages with all flags and copy-paste variations in [`docs/03-navigation/`](03-navigation/README.md), or run [`examples/03_navigation_example.sh`](../examples/03_navigation_example.sh).

| Function | Per-Function Docs & Flags | Runnable Example |
| :--- | :--- | :--- |
| `current_directory` | [Docs & Examples](03-navigation/current_directory.md) | [`03_navigation_example.sh`](../examples/03_navigation_example.sh) |
| `dir_up` | [Docs & Examples](03-navigation/dir_up.md) | [`03_navigation_example.sh`](../examples/03_navigation_example.sh) |
| `absolute_path` | [Docs & Examples](03-navigation/absolute_path.md) | [`03_navigation_example.sh`](../examples/03_navigation_example.sh) |
| `get_current_directory` | [Docs & Examples](03-navigation/get_current_directory.md) | [`03_navigation_example.sh`](../examples/03_navigation_example.sh) |
| `get_absolute_path` | [Docs & Examples](03-navigation/get_absolute_path.md) | [`03_navigation_example.sh`](../examples/03_navigation_example.sh) |
| `to_project_root` | [Docs & Examples](03-navigation/to_project_root.md) | [`03_navigation_example.sh`](../examples/03_navigation_example.sh) |
| `get_project_root` | [Docs & Examples](03-navigation/get_project_root.md) | [`03_navigation_example.sh`](../examples/03_navigation_example.sh) |
| `is_inside_git_repo` | [Docs & Examples](03-navigation/is_inside_git_repo.md) | [`03_navigation_example.sh`](../examples/03_navigation_example.sh) |
| `normalize_path` | [Docs & Examples](03-navigation/normalize_path.md) | [`03_navigation_example.sh`](../examples/03_navigation_example.sh) |
| `ensure_directory_exists` | [Docs & Examples](03-navigation/ensure_directory_exists.md) | [`03_navigation_example.sh`](../examples/03_navigation_example.sh) |
| `change_directory` | [Docs & Examples](03-navigation/change_directory.md) | [`03_navigation_example.sh`](../examples/03_navigation_example.sh) |