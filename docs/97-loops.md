# Zsh Loops Guide (Copy-Paste Reference for Beginners)

- **Guide File:** [`docs/97-loops.md`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/97-loops.md)
- **Description:** Copy-pasteable loop templates (`for`, `while`, `until`, `repeat`, `select`, `break`, `continue`) designed for novice users. Copy any block below into your script and change only the highlighted values to fit your needs.

---

## Table of Contents
1. [Quick Setup (Include at the Top of Your Script)](#1-quick-setup-include-at-the-top-of-your-script)
2. [Which Loop Should I Use? (Quick Picker)](#2-which-loop-should-i-use-quick-picker)
3. [`for` Loops (Repeat for Each Item in a List)](#3-for-loops-repeat-for-each-item-in-a-list)
   - [3.1 Loop Over a Simple List of Words](#31-loop-over-a-simple-list-of-words)
   - [3.2 Loop Over an Array Variable](#32-loop-over-an-array-variable)
   - [3.3 Loop Over a Range of Numbers (`{1..5}`)](#33-loop-over-a-range-of-numbers-15)
   - [3.4 Loop Over Numbers with a Step (`{0..20..5}`)](#34-loop-over-numbers-with-a-step-0205)
   - [3.5 C-Style Counter Loop (`for (( i=1; i<=5; i++ ))`)](#35-c-style-counter-loop-for--i1-i5-i-)
   - [3.6 Loop Over All Files in a Folder](#36-loop-over-all-files-in-a-folder)
   - [3.7 Loop Over Key-Value Pairs (Associative Array / Map)](#37-loop-over-key-value-pairs-associative-array--map)
4. [`repeat` Loop (Simplest Way to Run Something N Times)](#4-repeat-loop-simplest-way-to-run-something-n-times)
5. [`while` Loops (Repeat While a Condition is True)](#5-while-loops-repeat-while-a-condition-is-true)
   - [5.1 Counter `while` Loop](#51-counter-while-loop)
   - [5.2 Read a File Line-by-Line (`while read`)](#52-read-a-file-line-by-line-while-read)
   - [5.3 Read a CSV File Line-by-Line](#53-read-a-csv-file-line-by-line)
   - [5.4 Retry Loop (Try Until Attempts Run Out)](#54-retry-loop-try-until-attempts-run-out)
   - [5.5 Infinite Loop (`while true`)](#55-infinite-loop-while-true)
6. [`until` Loops (Repeat Until a Condition Becomes True)](#6-until-loops-repeat-until-a-condition-becomes-true)
   - [6.1 Wait Until a File Exists](#61-wait-until-a-file-exists)
   - [6.2 Counter `until` Loop](#62-counter-until-loop)
7. [`select` Loop (Interactive Numbered Menu)](#7-select-loop-interactive-numbered-menu)
8. [Controlling Loops (`break` and `continue`)](#8-controlling-loops-break-and-continue)
   - [8.1 Skip Current Item with `continue`](#81-skip-current-item-with-continue)
   - [8.2 Stop the Loop Early with `break`](#82-stop-the-loop-early-with-break)
9. [Ready-to-Use Framework Recipes](#9-ready-to-use-framework-recipes)

---

## 1. Quick Setup (Include at the Top of Your Script)

Paste these lines at the top of your `.sh` script so you can use both standard `echo` commands and framework logging helpers like `log_info`:

```zsh
#!/usr/bin/env zsh
source "${RZSH_DIR}/config/config.sh"
init_config
init_logging
```

---

## 2. Which Loop Should I Use? (Quick Picker)

| What You Want to Do | Best Loop to Copy |
| :--- | :--- |
| Run commands for a known list of items (servers, names, environments) | [`for item in ...`](#31-loop-over-a-simple-list-of-words) |
| Run a command exactly `N` times (e.g., 3 times) | [`repeat 3`](#4-repeat-loop-simplest-way-to-run-something-n-times) |
| Count from 1 to 10 | [`for num in {1..10}`](#33-loop-over-a-range-of-numbers-15) |
| Process every `.json` or `.txt` file in a folder | [`for file_path in ...`](#36-loop-over-all-files-in-a-folder) |
| Read a text or CSV file line-by-line | [`while IFS= read -r line`](#52-read-a-file-line-by-line-while-read) |
| Keep waiting while a condition is true | [`while [[ ... ]]`](#51-counter-while-loop) |
| Keep waiting until a file or service is ready | [`until [[ ... ]]`](#61-wait-until-a-file-exists) |

---

## 3. `for` Loops (Repeat for Each Item in a List)

### 3.1 Loop Over a Simple List of Words
**What to change:** Replace `"dev" "staging" "prod"` with your own values.

```zsh
for env_name in "dev" "staging" "prod"; do
  log_info "Processing environment: ${env_name}"
  # Put your commands here
done
```

---

### 3.2 Loop Over an Array Variable
**What to change:** Update the items inside `services=( ... )`.

```zsh
# 1. Define your list of items
services=(
  "auth-service"
  "payment-service"
  "notification-service"
)

# 2. Loop through every item in the list
for service in "${services[@]}"; do
  log_info "Checking ${service}..."
  # Put your commands here
done
```

---

### 3.3 Loop Over a Range of Numbers (`{1..5}`)
**What to change:** Change `1` (start) and `5` (end) in `{1..5}`.

```zsh
for i in {1..5}; do
  log_info "Step number: ${i}"
  # Put your commands here
done
```

---

### 3.4 Loop Over Numbers with a Step (`{0..20..5}`)
**What to change:** `{START..END..STEP}` — below counts from `0` to `20` going up by `5` each time (`0, 5, 10, 15, 20`).

```zsh
for num in {0..20..5}; do
  log_info "Current value: ${num}"
done
```

---

### 3.5 C-Style Counter Loop (`for (( i=1; i<=5; i++ ))`)
Use this when your start or end number is stored in a variable.
**What to change:** Change `total_steps=5` to your desired count.

```zsh
total_steps=5

for (( i = 1; i <= total_steps; i++ )); do
  log_info "Running task ${i} of ${total_steps}"
  # Put your commands here
done
```

---

### 3.6 Loop Over All Files in a Folder
> [!TIP]
> Adding `(N)` at the end of `*.txt(N)` is a Zsh safety feature: if the folder has no matching files, the loop safely skips instead of throwing a `no matches found` error.

**What to change:** Replace `./logs/*.log` with your folder path and file extension (e.g., `./data/*.json`).

```zsh
for file_path in ./logs/*.log(N); do
  log_info "Found file: ${file_path}"
  # Example: create a backup of each file
  # file_backup "${file_path}"
done
```

---

### 3.7 Loop Over Key-Value Pairs (Associative Array / Map)
Use this when you have pairs of data (like Server Name -> IP Address, or Repo Name -> Folder Path).
**What to change:** Edit the key-value pairs inside `servers=( ... )`.

```zsh
# 1. Declare a key-value map
typeset -A servers
servers=(
  "web-01" "192.168.1.10"
  "db-01"  "192.168.1.20"
  "cache"  "192.168.1.30"
)

# 2. Loop over both key and value
for server_name ip_address in "${(@kv)servers}"; do
  log_info "Server ${server_name} is at IP ${ip_address}"
done
```

---

## 4. `repeat` Loop (Simplest Way to Run Something N Times)

Zsh has a built-in `repeat` keyword. If you just want to run a block of commands 3 times without caring about a counter variable, copy this:

**What to change:** Replace `3` with how many times you want to repeat.

```zsh
repeat 3; do
  log_info "Pinging health check endpoint..."
  sleep 1
done
```

---

## 5. `while` Loops (Repeat While a Condition is True)

A `while` loop checks the condition **before** every run and keeps going as long as the condition is true.

### 5.1 Counter `while` Loop
**What to change:** Change `max_count=5` to control how many times it runs.

```zsh
count=1
max_count=5

while [[ ${count} -le ${max_count} ]]; do
  log_info "Attempt ${count} of ${max_count}"

  # Increase counter by 1
  (( count++ ))
done
```

---

### 5.2 Read a File Line-by-Line (`while read`)
This is the safest way to read a text file one line at a time (even if lines contain spaces).
**What to change:** Change `input_file="./my_list.txt"` to your file path.

```zsh
input_file="./my_list.txt"

if [[ -f "${input_file}" ]]; then
  while IFS= read -r line || [[ -n "${line}" ]]; do
    # Skip empty lines
    [[ -z "${line}" ]] && continue

    log_info "Read line: ${line}"
  done < "${input_file}"
else
  log_error "File not found: ${input_file}"
fi
```

---

### 5.3 Read a CSV File Line-by-Line
Splits each line by comma (`,`) into separate variables.
**What to change:** Change `name,email,role` to match your CSV columns, and `./users.csv` to your CSV file.

```zsh
csv_file="./users.csv"

while IFS=',' read -r name email role || [[ -n "${name}" ]]; do
  # Skip header row if it starts with "name"
  [[ "${name}" == "name" ]] && continue

  log_info "User: ${name} | Email: ${email} | Role: ${role}"
done < "${csv_file}"
```

---

### 5.4 Retry Loop (Try Until Attempts Run Out)
Great for network requests or commands that might fail temporarily.
**What to change:** Replace `curl -s https://example.com > /dev/null` with the command you want to retry.

```zsh
max_retries=3
attempt=1
success=false

while [[ ${attempt} -le ${max_retries} ]]; do
  log_info "Trying command (Attempt ${attempt}/${max_retries})..."

  if curl -s https://example.com > /dev/null; then
    log_info "Command succeeded!"
    success=true
    break
  fi

  log_warn "Command failed. Waiting 2 seconds before retry..."
  sleep 2
  (( attempt++ ))
done

if [[ "${success}" == false ]]; then
  log_error "All ${max_retries} attempts failed."
fi
```

---

### 5.5 Infinite Loop (`while true`)
Runs forever until you stop the script (`Ctrl+C`) or call `break` inside the loop.

```zsh
while true; do
  log_info "Checking status every 5 seconds... (Press Ctrl+C to stop)"
  sleep 5
done
```

---

## 6. `until` Loops (Repeat Until a Condition Becomes True)

An `until` loop is the exact opposite of `while`: it keeps running **while the condition is false**, and stops as soon as the condition becomes **true**.

### 6.1 Wait Until a File Exists
**What to change:** Change `target_file="./ready.txt"` to the file you are waiting for.

```zsh
target_file="./ready.txt"

until [[ -f "${target_file}" ]]; do
  log_info "Waiting for ${target_file} to be created..."
  sleep 2
done

log_info "File ${target_file} is now available! Proceeding..."
```

---

### 6.2 Counter `until` Loop
Runs until `count` becomes greater than `5`.

```zsh
count=1

until [[ ${count} -gt 5 ]]; do
  log_info "Count is ${count}"
  (( count++ ))
done
```

---

## 7. `select` Loop (Interactive Numbered Menu)

Displays an interactive numbered menu in the terminal and loops until the user picks `Quit`.
**What to change:** Edit the menu choices inside `options=( ... )`.

```zsh
PS3="Please enter your choice (number): "
options=("Check Status" "Run Backup" "View Logs" "Quit")

select choice in "${options[@]}"; do
  case "${choice}" in
    "Check Status")
      log_info "System is healthy."
      ;;
    "Run Backup")
      log_info "Starting backup..."
      ;;
    "View Logs")
      log_info "Showing recent logs..."
      ;;
    "Quit")
      log_info "Exiting menu."
      break
      ;;
    *)
      log_warn "Invalid selection. Please pick a valid number."
      ;;
  esac
done
```

---

## 8. Controlling Loops (`break` and `continue`)

### 8.1 Skip Current Item with `continue`
Use `continue` to skip the rest of the current loop step and jump straight to the next item.

```zsh
for item in "apple" "SKIP_ME" "banana" "cherry"; do
  if [[ "${item}" == "SKIP_ME" ]]; then
    log_warn "Skipping ${item}..."
    continue
  fi

  log_info "Processing ${item}"
done
```

---

### 8.2 Stop the Loop Early with `break`
Use `break` to exit the loop completely when you find what you are looking for or hit an error.

```zsh
for item in "step-1" "step-2" "STOP_HERE" "step-4"; do
  if [[ "${item}" == "STOP_HERE" ]]; then
    log_warn "Stopping loop early at ${item}!"
    break
  fi

  log_info "Completed ${item}"
done
```

---

## 9. Ready-to-Use Framework Recipes

### Recipe A: Loop Through All Registered Repositories (`REPO_NAMES`)
If you configured repositories using `config_set_repo_location` (from [`docs/15-variables.md`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/15-variables.md)), copy this loop to visit every repository:

```zsh
for repo_name in "${REPO_NAMES[@]}"; do
  repo_path=$(config_get_repo_location "${repo_name}")
  log_info "Checking repository '${repo_name}' at: ${repo_path}"
done
```

### Recipe B: Loop Over Items in a JSON Array (`jq`)
Loop through objects or strings inside a JSON array:

```zsh
json_data='["alice@example.com", "bob@example.com", "charlie@example.com"]'

for email in ${(f)"$(echo "${json_data}" | jq -r '.[]')"}; do
  if validate_email "${email}"; then
    log_info "Valid email: ${email}"
  fi
done
```
