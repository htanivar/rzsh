# Global Configuration Module Reference

- **Source File:** [`config/config.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/config/config.sh)
- **Description:** Manages core system environment and default configuration parameters.

---

## Detailed Usage Examples

### Integration Setup
To use the Global Configuration module, ensure the global configurations are initialized, then source the script file:

```zsh
source ./config/config.sh
init_config

source ./config/config.sh
```

---

## Function Signatures & Descriptions

### `init_config`

* **Signature:** `init_config`
* **Description:** Initializes the global configuration parameters (PROJECT_ROOT, LOG_DIR, LOG_LEVEL, etc.). Sets default values for variables if they are not already defined, prepends local bin path to PATH, and exports the variables to the shell environment.

#### Example Code:
```zsh
source config/config.sh
init_config
echo "Project Root is: $PROJECT_ROOT"
echo "Log Level is: $LOG_LEVEL" 
```

---
