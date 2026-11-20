# Zsh Modular Scripting Framework

A modular, reusable, and beginner-friendly shell scripting framework built on Zsh 5.8+. Designed so both engineers and non-technical users can build automation scripts using plain, readable building blocks.

> [!IMPORTANT]
> Set `export RZSH_DIR="/path/to/rzsh"` in your environment (`~/.zshrc`). Then, to load all framework functions in any script anywhere on your system, you only need two lines at the top: `source "${RZSH_DIR}/config/config.sh"` and `init_config`. That automatically loads every module in `functions/*.sh`! (If `RZSH_DIR` is not set, the framework advises you and falls back automatically.)
>
> See [**`GLOSSARY.md`**](GLOSSARY.md) for a complete quick-reference list of all framework **variables** and **functions**.
>
> **Navigation Trail:** `README.md` › [`GLOSSARY.md`](GLOSSARY.md) › [`docs/`](docs) › [`examples/`](examples) › [`tests/`](tests)

## Table of Contents
- [Quick Start: Create Your Own Script in 3 Steps](#quick-start-create-your-own-script-in-3-steps)
- [Framework Glossary (All Variables & Functions)](GLOSSARY.md)
- [Guide: Sending HTTP Calls & JSON Payloads (All 5 Ways)](#guide-sending-http-calls--json-payloads-all-5-ways)
- [Copy-Paste Recipes for Non-Technical Users](#copy-paste-recipes-for-non-technical-users)
- [Framework Directory Structure](#framework-directory-structure)
- [Module Reference Directory](#module-reference-directory)
- [Executable Example Scripts](#executable-example-scripts)
- [Console Reference Help Manual](#console-reference-help-manual)
- [Unit Testing](#unit-testing)
- [Frequently Asked Questions (FAQ)](#frequently-asked-questions-faq)

---

## Quick Start: Create Your Own Script in 3 Steps

Even if you have never written a shell script before, you can create your own automation script anywhere on your machine in 3 simple steps:

### Step 0 (One-Time Setup): Set `RZSH_DIR` in your environment
Add `RZSH_DIR` to your `~/.zshrc` (or export it in your terminal) so any script can find the framework without hardcoding relative paths:

```zsh
export RZSH_DIR="/home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh"
```

### Step 1: Create a new `.sh` file
Create a file named `my_script.sh` anywhere and paste this starter template:

```zsh
#!/usr/bin/env zsh

# 1. Load the framework via RZSH_DIR (this imports all helper functions automatically)
source "${RZSH_DIR}/config/config.sh"
init_config
init_logging

# 2. Write your steps using plain-English helper functions
log_section "My First Automation Script"
log_steps "Checking system status"

name=$(read_input "What is your name?" "Guest")
log_info "Hello, ${name}! Your script is running."
```

### Step 2: Make your script executable (one-time setup)
Run this command in your terminal so your computer knows `my_script.sh` can be run as a program:

```bash
chmod +x my_script.sh
```

### Step 3: Run your script!
```bash
./my_script.sh
```

---

## Guide: Sending HTTP Calls & JSON Payloads (All 5 Ways)

When calling REST APIs (`POST`, `PUT`, `PATCH`), typing JSON inside quotes on a single command line is hard to read and easy to break.

With this framework's HTTP module ([`functions/06-http.sh`](functions/06-http.sh)), **you do not have to pass messy escaped strings**. You can create a clean `.json` file and pass it directly as input!

### Way 1 (Recommended for Non-Technical Users): Pass a `.json` File Directly
Create a normal `.json` file (using any text editor or inside your script) and pass the file path directly to `http_post`, `http_put`, or `http_patch`:

1. **Create `payload.json`:**
   ```json
   {
     "username": "alice",
     "email": "alice@example.com",
     "department": "Operations",
     "active": true
   }
   ```

2. **Send `payload.json` in your script:**
   ```zsh
   #!/usr/bin/env zsh
   source "${RZSH_DIR}/config/config.sh"
   init_config

   # Pass the path to payload.json directly as the 2nd argument!
   response=$(http_post "https://httpbin.org/post" "./payload.json" "Content-Type: application/json")

   # Check the HTTP status code (e.g. 200 or 201) and response body
   status_code=$(check_status_code "${response}")
   body=$(http_get_body "${response}")

   echo "Status Code: ${status_code}"
   echo "Server received username: $(json_get_value "${body}" ".json.username")"
   ```

### Way 2: Use `curl`-Style `@payload.json` Syntax
If you are familiar with `curl -d @payload.json`, you can also prefix the file path with `@`:

```zsh
response=$(http_post "https://httpbin.org/post" "@./payload.json" "Content-Type: application/json")
```

### Way 3: Use a `.json` File as a Template and Customize Fields Before Sending
If you have a standard `payload.json` file on disk and only want to change one or two fields (such as an environment name or user input) before sending:

```zsh
# 1. Read the template .json file
payload=$(file_read "./payload.json")

# 2. Override specific fields dynamically
payload=$(json_set_value "${payload}" ".department" "Engineering")
payload=$(json_set_value "${payload}" ".environment" "production")

# 3. Send the updated payload
response=$(http_put "https://httpbin.org/put" "${payload}" "Content-Type: application/json")
```

### Way 4: Generate a `.json` File Inline Using a Multi-Line Block (`cat << 'EOF'`)
If you want your script to be self-contained without a separate file to manage, write clean multi-line JSON to a temporary `.json` file inside your script:

```zsh
payload_file="${PROJECT_ROOT}/logs/request.json"
register_temp_file "${payload_file}" # Automatically deletes the temp file when done

cat << 'EOF' > "${payload_file}"
{
  "project": "rzsh-automation",
  "notify": true,
  "approvers": ["alice", "bob"]
}
EOF

response=$(http_post "https://httpbin.org/post" "${payload_file}" "Content-Type: application/json")
cleanup_temp_files
```

### Way 5: Build JSON Step-by-Step with `json_set_value` (Or Short Inline String)
For dynamic scripts or tiny 1-field updates:

```zsh
# Option A: Build step-by-step using helper functions
payload='{}'
payload=$(json_set_value "${payload}" ".name" "Alice")
payload=$(json_set_value "${payload}" ".role" "admin")
response=$(http_post "https://httpbin.org/post" "${payload}" "Content-Type: application/json")

# Option B: Short inline string for a single field update
response=$(http_patch "https://httpbin.org/patch" '{"status":"approved"}' "Content-Type: application/json")
```

### Passing Multiple HTTP Headers (e.g., API Keys or Bearer Tokens)
To send authentication headers along with your `.json` file, separate headers with a newline (`$`'...\n...'``):

```zsh
headers=$'Content-Type: application/json\nAuthorization: Bearer YOUR_API_TOKEN_HERE'
response=$(http_post "https://httpbin.org/post" "./payload.json" "${headers}")
```

---

## Copy-Paste Recipes for Non-Technical Users

### Recipe 1: Ask the User Questions & Validate Their Answers
```zsh
#!/usr/bin/env zsh
source "${RZSH_DIR}/config/config.sh"
init_config

# Ask for input with a default value if they just press Enter
user=$(read_input "Enter your username" "admin")

# Ask for a password (characters are hidden as they type)
secret=$(read_password "Enter your password")

# Present a numbered menu so the user can pick 1, 2, or 3
env_name=$(select_option "Which environment do you want to deploy to?" "development staging production")

# Keep asking until they enter a valid email address
email=$(read_with_validation "Enter notification email" "validate_email")

# Yes/No confirmation before running an action
if confirm "Deploy to ${env_name} as ${user}?" "n"; then
  log_info "Starting deployment for ${user} (${email})..."
else
  log_warn "Deployment cancelled by user."
fi
```

### Recipe 2: Safely Back Up and Edit a File
```zsh
#!/usr/bin/env zsh
source "${RZSH_DIR}/config/config.sh"
init_config

target_file="./logs/app_settings.txt"
file_write "${target_file}" "mode=standard"

# Create a timestamped .bak copy before making changes
backup_path=$(file_backup "${target_file}")
log_info "Backup saved at: ${backup_path}"

# Append a ask line to the file
file_append "${target_file}" "updated_by=automation"

# If something goes wrong, restore from backup in one command:
# file_restore "${backup_path}"
```

### Recipe 3: Compare Two Git Branches and Generate a Markdown Report
```zsh
#!/usr/bin/env zsh
source "${RZSH_DIR}/config/config.sh"
init_config

# Compares 'main' and your current branch, saving a clean Markdown summary report
git_compare_branches --output "./logs/branch_diff_report.md" main
```

### Recipe 4: Find Release Commits Not Backported to the Default Branch
```zsh
#!/usr/bin/env zsh
source "${RZSH_DIR}/config/config.sh"
init_config

# 1. Detect default branch (develop/main/master) and pick a release branch
target_branch=$(git_detect_default_branch)
release_branch=$(git_pick_branch "Select release branch:" "release/*")

# 2. Highlight commits missing from the default branch (also available via scripts/04-git/check_release_backport.sh)
git_report_missed_commits "${target_branch}" "${release_branch}" "./logs/backport_report.md"
```

---

## Framework Directory Structure
```
.
├── README.md               # Main documentation & beginner guide
├── GLOSSARY.md             # Quick-reference catalog of all variables & functions
├── help.sh                 # Executable console reference help manual
├── test.sh                 # Unit test runner
├── config/
│   └── config.sh           # Global environment parameters (sources functions/*.sh)
├── functions/              # Modular functional scripts
│   ├── 01-logs.sh
│   ├── 02-errors.sh
│   ├── ...
│   ├── 06-http.sh          # HTTP GET/POST/PUT/PATCH/DELETE & .json file support
│   ├── 14-jq.sh            # JSON parsing & JQ query operations
│   └── 99-evidences.sh     # System evidence collector
├── examples/               # Executable example scripts for non-technical users
│   ├── 00_config_example.sh
│   ├── 06_http_example.sh  # Demonstrates all 5 ways to send HTTP JSON payloads
│   └── ...
├── tests/                  # Assertion-based unit tests
│   ├── test_helpers.sh
│   ├── 01-logs.test.sh
│   └── ...
└── docs/                   # Comprehensive per-module usage guides
    ├── 00-config.md
    ├── 06-http.md
    └── ...
```

## Module Reference Directory

Click on any module link to view its source, detailed usage guide, runnable example, or unit tests:

| ID | Module Name | Source File | Usage Guide | Example Script | Unit Tests |
|---|---|---|---|---|---|
| 00 | Global Configuration | [`config/config.sh`](config/config.sh) | [Usage Documentation](docs/00-config.md) | [`00_config_example.sh`](examples/00_config_example.sh) | — |
| 01 | Logging Utility | [`functions/01-logs.sh`](functions/01-logs.sh) | [Usage Documentation](docs/01-logs.md) | [`01_logs_example.sh`](examples/01_logs_example.sh) | [`01-logs.test.sh`](tests/01-logs.test.sh) |
| 02 | Error Handling | [`functions/02-errors.sh`](functions/02-errors.sh) | [Usage Documentation](docs/02-errors.md) | [`02_errors_example.sh`](examples/02_errors_example.sh) | [`02-errors.test.sh`](tests/02-errors.test.sh) |
| 03 | File Navigation & Git Checks | [`functions/03-navigation.sh`](functions/03-navigation.sh) | [Usage Documentation](docs/03-navigation.md) | [`03_navigation_example.sh`](examples/03_navigation_example.sh) | [`03-navigation.test.sh`](tests/03-navigation.test.sh) |
| 04 | Input & Format Validation | [`functions/04-validation.sh`](functions/04-validation.sh) | [Usage Documentation](docs/04-validation.md) | [`04_validation_example.sh`](examples/04_validation_example.sh) | [`04-validation.test.sh`](tests/04-validation.test.sh) |
| 05 | Git Operations | [`functions/05-git.sh`](functions/05-git.sh) | [Usage Documentation](docs/05-git.md) | [`05_git_example.sh`](examples/05_git_example.sh) | [`05-git.test.sh`](tests/05-git.test.sh) |
| 06 | HTTP Client Wrapper | [`functions/06-http.sh`](functions/06-http.sh) | [Usage Documentation](docs/06-http.md) | [`06_http_example.sh`](examples/06_http_example.sh) | [`06-http.test.sh`](tests/06-http.test.sh) |
| 07 | Interactive Prompts | [`functions/07-user-actions.sh`](functions/07-user-actions.sh) | [Usage Documentation](docs/07-user-actions.md) | [`07_user_actions_example.sh`](examples/07_user_actions_example.sh) | [`07-user-actions.test.sh`](tests/07-user-actions.test.sh) |
| 08 | Time & Duration | [`functions/08-datetime.sh`](functions/08-datetime.sh) | [Usage Documentation](docs/08-datetime.md) | [`08_datetime_example.sh`](examples/08_datetime_example.sh) | [`08-datetime.test.sh`](tests/08-datetime.test.sh) |
| 09 | File Utilities | [`functions/09-file.sh`](functions/09-file.sh) | [Usage Documentation](docs/09-file.md) | [`09_file_example.sh`](examples/09_file_example.sh) | [`09-file.test.sh`](tests/09-file.test.sh) |
| 10 | Directory Management | [`functions/10-directory.sh`](functions/10-directory.sh) | [Usage Documentation](docs/10-directory.md) | [`10_directory_example.sh`](examples/10_directory_example.sh) | [`10-directory.test.sh`](tests/10-directory.test.sh) |
| 11 | String Formatting | [`functions/11-string.sh`](functions/11-string.sh) | [Usage Documentation](docs/11-string.md) | [`11_string_example.sh`](examples/11_string_example.sh) | [`11-string.test.sh`](tests/11-string.test.sh) |
| 12 | SSH & SCP Client | [`functions/12-ssh.sh`](functions/12-ssh.sh) | [Usage Documentation](docs/12-ssh.md) | [`12_ssh_example.sh`](examples/12_ssh_example.sh) | [`12-ssh.test.sh`](tests/12-ssh.test.sh) |
| 13 | JSON Web Tokens | [`functions/13-jwt.sh`](functions/13-jwt.sh) | [Usage Documentation](docs/13-jwt.md) | [`13_jwt_example.sh`](examples/13_jwt_example.sh) | [`13-jwt.test.sh`](tests/13-jwt.test.sh) |
| 14 | JQ JSON Parser | [`functions/14-jq.sh`](functions/14-jq.sh) | [Usage Documentation](docs/14-jq.md) | [`14_jq_example.sh`](examples/14_jq_example.sh) | [`14-jq.test.sh`](tests/14-jq.test.sh) |
| 15 | Config Variables & Repos | [`functions/15-variables.sh`](functions/15-variables.sh) | [Usage Documentation](docs/15-variables.md) | [`15_variables_example.sh`](examples/15_variables_example.sh) | [`17-variables.test.sh`](tests/17-variables.test.sh) |
| 16 | Data Masking & Redaction | [`functions/16-mask.sh`](functions/16-mask.sh) | [Usage Documentation](docs/16-mask.md) | [`16_mask_example.sh`](examples/16_mask_example.sh) | [`16-mask.test.sh`](tests/16-mask.test.sh) |
| 17 | Mocking & Test Stubs | [`functions/17-mock.sh`](functions/17-mock.sh) | [Usage Documentation](docs/17-mock.md) | [`17_mock_example.sh`](examples/17_mock_example.sh) | [`17-mock.test.sh`](tests/17-mock.test.sh) |
| 18 | Script Executory | [`functions/18-script-executory.sh`](functions/18-script-executory.sh) | [Usage Documentation](docs/18-script-executory.md) | [`18_script_executory_example.sh`](examples/18_script_executory_example.sh) | [`18-script-executory.test.sh`](tests/18-script-executory.test.sh) |
| 19 | Secrets & Token Cache | [`functions/19-cache.sh`](functions/19-cache.sh) | [Usage Documentation](docs/19-cache.md) | [`19_cache_example.sh`](examples/19_cache_example.sh) | [`19-cache.test.sh`](tests/19-cache.test.sh) |
| 97 | Zsh Loops Guide (Beginner Copy-Paste) | — | [Usage Documentation](docs/97-loops.md) | — | — |
| 98 | Zsh Control Statements Guide (Beginner Copy-Paste) | — | [Usage Documentation](docs/98-control-statements.md) | — | — |
| 99 | Evidence Collector | [`functions/99-evidences.sh`](functions/99-evidences.sh) | [Usage Documentation](docs/99-evidences.md) | [`99_evidences_example.sh`](examples/99_evidences_example.sh) | [`99-evidences.test.sh`](tests/99-evidences.test.sh) |

## Executable Example Scripts

Ready-to-run, commented example scripts for every module are located in [`examples/`](examples):

- [`examples/00_config_example.sh`](examples/00_config_example.sh) — Initializing global paths and defaults
- [`examples/01_logs_example.sh`](examples/01_logs_example.sh) — Colored console logs, step counters, and log files
- [`examples/02_errors_example.sh`](examples/02_errors_example.sh) — Automatic temporary file cleanup and error exits
- [`examples/03_navigation_example.sh`](examples/03_navigation_example.sh) — Directory navigation and project root lookup
- [`examples/04_validation_example.sh`](examples/04_validation_example.sh) — Validating emails, URLs, numbers, dates, and JSON
- [`examples/05_git_example.sh`](examples/05_git_example.sh) — Checking Git status, branch names, and branch diffs
- [`examples/06_http_example.sh`](examples/06_http_example.sh) — HTTP GET/POST/PUT/PATCH/DELETE and all 5 ways to pass `.json` file payloads
- [`examples/07_user_actions_example.sh`](examples/07_user_actions_example.sh) — Interactive prompts, hidden passwords, and menus
- [`examples/08_datetime_example.sh`](examples/08_datetime_example.sh) — Date math, timestamps, and duration formatting
- [`examples/09_file_example.sh`](examples/09_file_example.sh) — Reading, writing, backing up, and hashing files
- [`examples/10_directory_example.sh`](examples/10_directory_example.sh) — Creating, listing, syncing, and cleaning folders
- [`examples/11_string_example.sh`](examples/11_string_example.sh) — Trimming, splitting, joining, slugifying, and UUIDs
- [`examples/12_ssh_example.sh`](examples/12_ssh_example.sh) — Remote SSH commands, SCP transfers, and tunnels
- [`examples/13_jwt_example.sh`](examples/13_jwt_example.sh) — Generating, decoding, and verifying JWT tokens
- [`examples/14_jq_example.sh`](examples/14_jq_example.sh) — Reading, updating, and converting JSON to YAML
- [`examples/15_variables_example.sh`](examples/15_variables_example.sh) — Managing global variables and repository locations
- [`examples/16_mask_example.sh`](examples/16_mask_example.sh) — Masking secrets, tokens, PII, JSON fields, and config lines
- [`examples/17_mock_example.sh`](examples/17_mock_example.sh) — Generating dummy strings, passwords, JWTs, Vault tokens, arrays, JSON, and mocking CLI/HTTP calls
- [`examples/18_script_executory_example.sh`](examples/18_script_executory_example.sh) — Executing existing scripts in sequence, sharing state, and running manifest pipelines
- [`examples/19_cache_example.sh`](examples/19_cache_example.sh) — Caching secrets and JWT tokens in `.secrets.d` with TTL expiry and login deduplication
- [`examples/99_evidences_example.sh`](examples/99_evidences_example.sh) — Collecting audit evidence snapshots and archives

## Console Reference Help Manual

Display a colored reference manual directly in your terminal by running:

```bash
PATH="/home/ubuntu/.local/bin:$PATH" ./help.sh
```

## Unit Testing

Run the full unit test suite (or test individual modules) using:

```bash
PATH="/home/ubuntu/.local/bin:$PATH" ./test.sh
```

## Frequently Asked Questions (FAQ)

### Why are JSDoc blocks commented out with `# `?
In Zsh, `/**` behaves as a recursive glob operator by default. If a comment starts with `/**` without being prepended with `# `, Zsh tries to scan the filesystem for matching files, triggering `no matches found` or permission errors. Prepending `# ` treats the block as comments.

### Why is `local path` avoided in Zsh?
In Zsh, `path` is a special array tied directly to the `PATH` environment variable. Declaring `local path` and assigning a value (e.g. `.user.name`) modifies the shell's command resolution path, breaking external calls like `jq`. Always use `json_path` or `target_path` instead.

### Why is `local status` avoided in Zsh?
In Zsh, `status` is a read-only variable alias to `$?`. Trying to declare `local status` causes Zsh to exit immediately with a `read-only variable: status` error. Use `exit_code` or `http_status` instead.
