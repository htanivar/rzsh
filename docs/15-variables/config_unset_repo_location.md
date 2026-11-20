# `config_unset_repo_location`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../15-variables.md) › [Function Index](README.md) › **`config_unset_repo_location`** › [Runnable Example](../../examples/15_variables_example.sh) › [Tests](../../tests/17-variables.test.sh)

- **Source:** [`functions/15-variables.sh#L127-L135`](../../functions/15-variables.sh#L127-L135)
- **Signature:** `config_unset_repo_location <repo_name>`
- **Description:** Unregisters a repository's location from REPO_LOCATIONS and removes it from the REPO_NAMES list.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `repo_name` (`string`) | The name of the repository to remove. |

## Return / Exit Value

- {number} 0 on success, or non-zero on failure.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  config_unset_repo_location "service1"
```

---

See also the full runnable example script: [`examples/15_variables_example.sh`](../../examples/15_variables_example.sh).
