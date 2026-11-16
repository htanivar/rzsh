# Global Configuration Module Reference

**Navigation:** [README](../README.md) › [GLOSSARY](../GLOSSARY.md) › **00-config.md** › [Example](../examples/00_config_example.sh)

- **Source File:** [`config/config.sh`](../config/config.sh)
- **Description:** Manages core system environment, default configuration parameters, `RZSH_DIR` resolution, and dynamically loads all framework function modules automatically.

---

## Detailed Usage Examples

### Environment Setup (`RZSH_DIR`)
To use the framework from any script anywhere on your system without hardcoding relative paths, set `RZSH_DIR` in your shell profile (e.g., `~/.zshrc`):

```zsh
export RZSH_DIR="/path/to/shared/rzsh"
```

> **Note:** If `RZSH_DIR` is not set in the environment when `config/config.sh` is sourced, the framework prints a helpful warning advising you to set `export RZSH_DIR="..."` and automatically falls back to the resolved framework directory.

### Integration Setup
To load the Global Configuration module and all framework functions in any script, simply source `$RZSH_DIR/config/config.sh` and run `init_config`:

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

---

## Configuration Variables (Keys)

The following variable keys are defined in [`config/config.sh`](../config/config.sh) and initialized/exported by `init_config` (values are omitted so you can override any key in your environment prior to calling `init_config`):

| Variable Key | Type | Exported | Purpose |
| :--- | :--- | :---: | :--- |
| `RZSH_DIR` | String (Path) | Yes | Root directory of the `rzsh` framework; used to locate `config/config.sh` and `functions/*.sh`. |
| `PROJECT_ROOT` | String (Path) | Yes | Active project root directory (defaults to `RZSH_DIR` if not pre-set). |
| `LOG_LEVEL` | String | Yes | Minimum logging severity level (`DEBUG`, `INFO`, `WARN`, `ERROR`). |
| `LOG_DIR` | String (Path) | Yes | Directory path where script execution log files are stored. |
| `SCRIPT_NAME` | String | Yes | Basename of the currently executing script, used in log file naming. |
| `TIMESTAMP_FORMAT` | String | Yes | `strftime` format string used for log and evidence timestamps. |
| `DATE_FORMAT` | String | Yes | `strftime` format string used for calendar date outputs. |
| `JWT_SECRET` | String (Secret) | Yes | Default secret key used for HS256 JWT token signing and verification. |
| `EVIDENCE_DIR` | String (Path) | Yes | Base directory where execution and audit evidence session folders are created. |
| `RAVI_DIR` | String (Path) | Yes | Custom workspace/user directory variable exported for user scripts. |
| `GIT_IGNORE_FOLDERS` | String (CSV) | Yes | Comma-separated list of directories to ignore during Git branch comparisons. |
| `HTTP_CONTENT_TYPE` | String | Yes | Default `Content-Type` header value (defaults to `application/json`). |
| `HTTP_ACCEPT` | String | Yes | Default `Accept` header value (defaults to `application/json`). |
| `HTTP_AUTH_TOKEN` | String (Secret) | Yes | Optional Bearer token; when set, populates `Authorization: Bearer <token>` in `HTTP_DEFAULT_HEADERS`. |
| `HTTP_VAULT_TOKEN` | String (Secret) | Yes | Optional Vault token; when set, populates `X-Vault-Token` in `HTTP_DEFAULT_HEADERS`. |
| `HTTP_VAULT_REQUEST` | String | Yes | Optional flag (e.g., `true`); when set, populates `X-Vault-Request` in `HTTP_DEFAULT_HEADERS`. |
| `HTTP_DEFAULT_HEADERS` | String (Newline-separated) | Yes | Newline-separated `"Key: Value"` default HTTP headers initialized by `init_config` and managed via [`06-http.sh`](../functions/06-http.sh). |
| `REPO_NAMES` | Array (`typeset -g -a`) | Global | Indexed array of registered repository names managed via [`15-variables.sh`](../functions/15-variables.sh). |
| `REPO_LOCATIONS` | Associative Array (`typeset -g -A`) | Global | Associative map of repository names to their filesystem directory paths. |

---

## Function Signatures & Descriptions

### `init_config`

* **Signature:** `init_config`
* **Description:** Validates that `RZSH_DIR` and `PROJECT_ROOT` exist, sets default values for all framework configuration variables if not already defined in the environment, prepends the local binary directory to `PATH`, and exports the configuration keys to subshells.
* **Variables Set & Exported by `init_config`:**
  * `RZSH_DIR`
  * `PROJECT_ROOT`
  * `LOG_LEVEL`
  * `LOG_DIR`
  * `SCRIPT_NAME`
  * `TIMESTAMP_FORMAT`
  * `DATE_FORMAT`
  * `JWT_SECRET`
  * `EVIDENCE_DIR`
  * `RAVI_DIR`
  * `GIT_IGNORE_FOLDERS`
  * `HTTP_CONTENT_TYPE`
  * `HTTP_ACCEPT`
  * `HTTP_AUTH_TOKEN`
  * `HTTP_VAULT_TOKEN`
  * `HTTP_VAULT_REQUEST`
  * `HTTP_DEFAULT_HEADERS`
  * `PATH` (prepends local bin directory)

#### Example Code:
```zsh
# Source config.sh via RZSH_DIR - it automatically loads ALL functions!
source "${RZSH_DIR}/config/config.sh"
init_config

echo "RZSH Framework Root is: $RZSH_DIR"
echo "Project Root is:        $PROJECT_ROOT"
```

---
