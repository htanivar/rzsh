# Zsh Modular Scripting Framework

A modular, reusable, and beginner-friendly shell scripting framework built on Zsh 5.8+. Designed so both engineers and non-technical users can build automation scripts using plain, readable building blocks.

> [!IMPORTANT]
> Set `export RZSH_DIR="/path/to/rzsh"` in your environment (`~/.zshrc`). Then, to load all framework functions in any script anywhere on your system, you only need two lines at the top: `source "${RZSH_DIR}/config/config.sh"` and `init_config`. That automatically loads every module in `functions/*.sh`! (If `RZSH_DIR` is not set, the framework advises you and falls back automatically.)
>
> See [**`GLOSSARY.md`**](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/GLOSSARY.md) for a complete quick-reference list of all framework **variables** and **functions**.

## Table of Contents
- [Quick Start: Create Your Own Script in 3 Steps](#quick-start-create-your-own-script-in-3-steps)
- [Framework Glossary (All Variables & Functions)](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/GLOSSARY.md)
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

With this framework's HTTP module ([`functions/06-http.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/06-http.sh)), **you do not have to pass messy escaped strings**. You can create a clean `.json` file and pass it directly as input!

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

# Append a new line to the file
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

Click on any module link to view its detailed usage guide and function signatures:

| ID | Module Name | Source File | Usage Guide |
|---|---|---|---|
| 00 | Global Configuration | [`config/config.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/config/config.sh) | [Usage Documentation](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/00-config.md) |
| 01 | Logging Utility | [`functions/01-logs.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/01-logs.sh) | [Usage Documentation](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/01-logs.md) |
| 02 | Error Handling | [`functions/02-errors.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/02-errors.sh) | [Usage Documentation](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/02-errors.md) |
| 03 | File Navigation & Git Checks | [`functions/03-navigation.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/03-navigation.sh) | [Usage Documentation](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/03-navigation.md) |
| 04 | Input & Format Validation | [`functions/04-validation.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/04-validation.sh) | [Usage Documentation](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/04-validation.md) |
| 05 | Git Operations | [`functions/05-git.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/05-git.sh) | [Usage Documentation](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/05-git.md) |
| 06 | HTTP Client Wrapper | [`functions/06-http.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/06-http.sh) | [Usage Documentation](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/06-http.md) |
| 07 | Interactive Prompts | [`functions/07-user-actions.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/07-user-actions.sh) | [Usage Documentation](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/07-user-actions.md) |
| 08 | Time & Duration | [`functions/08-datetime.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/08-datetime.sh) | [Usage Documentation](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/08-datetime.md) |
| 09 | File Utilities | [`functions/09-file.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/09-file.sh) | [Usage Documentation](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/09-file.md) |
| 10 | Directory Management | [`functions/10-directory.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/10-directory.sh) | [Usage Documentation](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/10-directory.md) |
| 11 | String Formatting | [`functions/11-string.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/11-string.sh) | [Usage Documentation](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/11-string.md) |
| 12 | SSH & SCP Client | [`functions/12-ssh.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/12-ssh.sh) | [Usage Documentation](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/12-ssh.md) |
| 13 | JSON Web Tokens | [`functions/13-jwt.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/13-jwt.sh) | [Usage Documentation](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/13-jwt.md) |
| 14 | JQ JSON Parser | [`functions/14-jq.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/14-jq.sh) | [Usage Documentation](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/14-jq.md) |
| 15 | Config Variables & Repos | [`functions/15-variables.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/15-variables.sh) | [Usage Documentation](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/15-variables.md) |
| 97 | Zsh Loops Guide (Beginner Copy-Paste) | — | [Usage Documentation](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/97-loops.md) |
| 98 | Zsh Control Statements Guide (Beginner Copy-Paste) | — | [Usage Documentation](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/98-control-statements.md) |
| 99 | Evidence Collector | [`functions/99-evidences.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/99-evidences.sh) | [Usage Documentation](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/99-evidences.md) |

## Executable Example Scripts

Ready-to-run, commented example scripts for every module are located in [`examples/`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/examples):

- [`examples/00_config_example.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/examples/00_config_example.sh) — Initializing global paths and defaults
- [`examples/01_logs_example.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/examples/01_logs_example.sh) — Colored console logs, step counters, and log files
- [`examples/02_errors_example.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/examples/02_errors_example.sh) — Automatic temporary file cleanup and error exits
- [`examples/03_navigation_example.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/examples/03_navigation_example.sh) — Directory navigation and project root lookup
- [`examples/04_validation_example.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/examples/04_validation_example.sh) — Validating emails, URLs, numbers, dates, and JSON
- [`examples/05_git_example.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/examples/05_git_example.sh) — Checking Git status, branch names, and branch diffs
- [`examples/06_http_example.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/examples/06_http_example.sh) — HTTP GET/POST/PUT/PATCH/DELETE and all 5 ways to pass `.json` file payloads
- [`examples/07_user_actions_example.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/examples/07_user_actions_example.sh) — Interactive prompts, hidden passwords, and menus
- [`examples/08_datetime_example.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/examples/08_datetime_example.sh) — Date math, timestamps, and duration formatting
- [`examples/09_file_example.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/examples/09_file_example.sh) — Reading, writing, backing up, and hashing files
- [`examples/10_directory_example.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/examples/10_directory_example.sh) — Creating, listing, syncing, and cleaning folders
- [`examples/11_string_example.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/examples/11_string_example.sh) — Trimming, splitting, joining, slugifying, and UUIDs
- [`examples/12_ssh_example.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/examples/12_ssh_example.sh) — Remote SSH commands, SCP transfers, and tunnels
- [`examples/13_jwt_example.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/examples/13_jwt_example.sh) — Generating, decoding, and verifying JWT tokens
- [`examples/14_jq_example.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/examples/14_jq_example.sh) — Reading, updating, and converting JSON to YAML
- [`examples/15_variables_example.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/examples/15_variables_example.sh) — Managing global variables and repository locations
- [`examples/99_evidences_example.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/examples/99_evidences_example.sh) — Collecting audit evidence snapshots and archives

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
