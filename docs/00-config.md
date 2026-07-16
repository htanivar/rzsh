# Global Configuration Module Reference

- **Source File:** [`config/config.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/config/config.sh)
- **Description:** Manages core system environment, default configuration parameters, and dynamically loads all functions automatically.

---

## Detailed Usage Examples

### Integration Setup
To use the Global Configuration module, you only need to source the configuration script, which automatically imports it:

```zsh
source ./config/config.sh
init_config
```

---

## Configuration Variables

### `GIT_IGNORE_FOLDERS`
* **Default:** `vendor,.idea,.git`
* **Description:** Comma-separated list of directories to ignore during Git branch comparisons (e.g. `vendor`, `.idea`, `.git`).

---

## Function Signatures & Descriptions

### `init_config`

* **Signature:** `init_config`
* **Description:** Initializes the global configuration parameters (PROJECT_ROOT, LOG_DIR, LOG_LEVEL, etc.). Sets default values for variables if they are not already defined, prepends local bin path to PATH, and exports the variables to the shell environment. Also sources all module functions dynamically in numerical order.

#### Example Code:
```zsh
# Simply source config.sh - it will automatically load ALL functions!
source config/config.sh
init_config
echo "Project Root is: $PROJECT_ROOT" 
```

---
