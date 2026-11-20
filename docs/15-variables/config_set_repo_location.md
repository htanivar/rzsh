# `config_set_repo_location`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../15-variables.md) › [Function Index](README.md) › **`config_set_repo_location`** › [Runnable Example](../../examples/15_variables_example.sh) › [Tests](../../tests/17-variables.test.sh)

- **Source:** [`functions/15-variables.sh#L105-L117`](../../functions/15-variables.sh#L105-L117)
- **Signature:** `config_set_repo_location <repo_name> <location>`
- **Description:** Configures the directory path of a repository inside REPO_LOCATIONS, and registers it in REPO_NAMES if not already present.

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
| `location` (`string`) | The absolute path of the repository. |

## Return / Exit Value

- {number} 0 on success, or non-zero on failure.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  config_set_repo_location "service4" "/home/ubuntu/service4"
```

---

See also the full runnable example script: [`examples/15_variables_example.sh`](../../examples/15_variables_example.sh).
