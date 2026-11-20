# Navigation & Paths — Function Index

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../03-navigation.md) › **03-navigation/** › [Runnable Example](../../examples/03_navigation_example.sh) › [Tests](../../tests/03-navigation.test.sh)

- **Source File:** [`functions/03-navigation.sh`](../../functions/03-navigation.sh)
- **Runnable Example:** [`examples/03_navigation_example.sh`](../../examples/03_navigation_example.sh)

| Function | Signature | Description |
| :--- | :--- | :--- |
| [`current_directory`](current_directory.md) | `current_directory` | Returns the absolute path of the current working directory. |
| [`dir_up`](dir_up.md) | `dir_up [n=1]` | Returns the path resulting from moving up 'n' directories from the current directory. |
| [`absolute_path`](absolute_path.md) | `absolute_path <relative_path>` | Converts a relative path into an absolute path using Zsh modifiers. |
| [`get_current_directory`](get_current_directory.md) | `get_current_directory` | Framework function `get_current_directory`. |
| [`get_absolute_path`](get_absolute_path.md) | `get_absolute_path` | Framework function `get_absolute_path`. |
| [`to_project_root`](to_project_root.md) | `to_project_root` | Changes the current working directory to the project root directory. |
| [`get_project_root`](get_project_root.md) | `get_project_root` | Returns the absolute path of the project root directory. |
| [`is_inside_git_repo`](is_inside_git_repo.md) | `is_inside_git_repo` | Checks if the current directory is inside a Git repository. |
| [`normalize_path`](normalize_path.md) | `normalize_path <path>` | Normalizes a path by resolving relative components (. and ..) and symbolic links. |
| [`ensure_directory_exists`](ensure_directory_exists.md) | `ensure_directory_exists <path>` | Creates the specified directory and any parent directories if they do not exist. |
| [`change_directory`](change_directory.md) | `change_directory <path>` | Changes the current working directory to the specified path. |
