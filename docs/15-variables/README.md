# Dynamic Variables & Repo Registry — Function Index

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../15-variables.md) › **15-variables/** › [Runnable Example](../../examples/15_variables_example.sh) › [Tests](../../tests/17-variables.test.sh)

- **Source File:** [`functions/15-variables.sh`](../../functions/15-variables.sh)
- **Runnable Example:** [`examples/15_variables_example.sh`](../../examples/15_variables_example.sh)

| Function | Signature | Description |
| :--- | :--- | :--- |
| [`config_get_var`](config_get_var.md) | `config_get_var <var_name> [default_value]` | Retrieves the value of a global configuration variable, returning a default value if the variable is unset or empty. |
| [`config_set_var`](config_set_var.md) | `config_set_var <var_name> <value>` | Sets the value of a global configuration variable dynamically. |
| [`config_unset_var`](config_unset_var.md) | `config_unset_var <var_name>` | Unsets/removes a global configuration variable. |
| [`config_get_repo_location`](config_get_repo_location.md) | `config_get_repo_location <repo_name>` | Gets the location of a repository from the REPO_LOCATIONS configuration map. |
| [`config_set_repo_location`](config_set_repo_location.md) | `config_set_repo_location <repo_name> <location>` | Configures the directory path of a repository inside REPO_LOCATIONS, and registers it in REPO_NAMES if not already present. |
| [`config_unset_repo_location`](config_unset_repo_location.md) | `config_unset_repo_location <repo_name>` | Unregisters a repository's location from REPO_LOCATIONS and removes it from the REPO_NAMES list. |
| [`config_list_repos`](config_list_repos.md) | `config_list_repos` | Prints all registered repository names and their mapped locations. |
