# `config_get_repo_location`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../15-variables.md) › [Function Index](README.md) › **`config_get_repo_location`** › [Runnable Example](../../examples/15_variables_example.sh) › [Tests](../../tests/17-variables.test.sh)

- **Source:** [`functions/15-variables.sh#L87-L94`](../../functions/15-variables.sh#L87-L94)
- **Signature:** `config_get_repo_location <repo_name>`
- **Description:** Gets the location of a repository from the REPO_LOCATIONS configuration map.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `repo_name` (`string`) | The name of the repository. |

## Return / Exit Value

- {string} The repository directory location path.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  local loc
  loc=$(config_get_repo_location "service1")
```

---

See also the full runnable example script: [`examples/15_variables_example.sh`](../../examples/15_variables_example.sh).
