# RZSH & Zsh Scripting Cheatsheet (For Beginners)

**Navigation:** [README](README.md) › [GLOSSARY](GLOSSARY.md) › **CHEATSHEET** › [Loops Guide](docs/97-loops.md) › [Control Statements](docs/98-control-statements.md)

A practical, copy-pasteable **"Zsh & `rzsh` for Dummies"** cheatsheet covering everyday Zsh syntax (1-indexed arrays, associative maps, conversions, loops, conditionals) alongside the `rzsh` framework helpers.

---

## 1. Two-Line Framework Setup

Put these lines at the top of any `.sh` script to load all `rzsh` functions and variables:

```zsh
#!/usr/bin/env zsh
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

source "${RZSH_DIR}/config/config.sh"
init_config
init_logging   # optional: enables log file + timestamps
```

---

## 2. Variables & Safe Defaults

```zsh
# Assign (NO spaces around '=')
name="Alice"
count=42
readonly APP_ENV="prod"

# Safe defaults (use fallback if unset or empty)
env_name="${APP_ENV:-dev}"          # returns "dev" if APP_ENV is empty/unset
port="${PORT:-8080}"

# Check if variable is empty or non-empty
[[ -z "${name}" ]] && echo "Empty"
[[ -n "${name}" ]] && echo "Has value: ${name}"

# Integer arithmetic
(( count++ ))
total=$(( count + 8 ))
```

---

## 3. Single-Dimensional Arrays (Zsh is 1-Indexed!)

> [!IMPORTANT]
> Unlike Bash (0-indexed), **Zsh arrays start at index `1`**.

```zsh
# Declare & populate
typeset -a fruits
fruits=("apple" "banana" "cherry")

# Append items
fruits+=("date")
fruits+=("elderberry" "fig")

# Get values
echo "${fruits[1]}"        # "apple" (first element)
echo "${fruits[-1]}"       # "fig"   (last element)
echo "${fruits[@]}"        # all elements
echo "${#fruits}"          # length (6)

# Slice (indices 2 through 4)
echo "${fruits[2,4]}"      # banana cherry date

# Safe helper from rzsh (11-string.sh)
second=$(array_get_element "fruits" 2)   # "banana"

# Loop over array
for item in "${fruits[@]}"; do
  echo "Fruit: ${item}"
done

# Loop with index
for (( i = 1; i <= ${#fruits}; i++ )); do
  echo "[$i] ${fruits[$i]}"
done

# Check if element exists in array
if (( ${fruits[(Ie)banana]} )); then
  echo "Found banana!"
fi
```

---

## 4. Multi-Dimensional / Nested Data & Associative Arrays

Zsh does not have native `arr[i][j]` syntax, so you handle 2D/nested data in three clean ways:

### A. Associative Arrays (Key-Value Maps / Dictionaries)
```zsh
typeset -A env_urls
env_urls=(
  [dev]="https://dev.api.local"
  [staging]="https://stg.api.local"
  [prod]="https://api.example.com"
)

# Get, set, delete
echo "${env_urls[prod]}"
env_urls[qa]="https://qa.api.local"
unset 'env_urls[dev]'

# Loop over keys & values
for env_key in "${(@k)env_urls}"; do
  echo "${env_key} -> ${env_urls[$env_key]}"
done

# Emulate 2D lookup using composite keys ("row,col")
typeset -A matrix
matrix[1,1]="a11"
matrix[1,2]="a12"
matrix[2,1]="a21"
echo "${matrix[1,2]}"      # "a12"
```

### B. 2D / Multi-Dimensional Data via JSON (`14-jq.sh`)
Best for real multi-dimensional arrays, nested objects, and API responses:

```zsh
grid='[[10, 20, 30], [40, 50, 60]]'

# Get row 1, col 2 (jq uses 0-based indexing!)
val=$(json_get_value "${grid}" ".[1][2]")     # 60

# Extract nested object fields
user='{"name":"Alice","roles":["admin","ops"],"meta":{"team":"core"}}'
team=$(json_get_value "${user}" ".meta.team")       # "core"
role0=$(json_get_value "${user}" ".roles[0]")       # "admin"
```

### C. Delimited Rows (CSV / Table Rows in a 1D Array)
```zsh
rows=(
  "payments-api:prod:8080"
  "orders-api:staging:8081"
)

for row in "${rows[@]}"; do
  parts=( ${(s/:/)row} )   # split row on ':'
  echo "Service=${parts[1]} Env=${parts[2]} Port=${parts[3]}"
done
```

---

## 5. Common Conversions

| Conversion | Copy-Paste Snippet | Module |
| :--- | :--- | :--- |
| **String → Array** | `str_to_array "a,b,c" "," "MY_ARR"` or `arr=( ${(s:,:)str} )` | [`11-string.sh`](docs/11-string/str_to_array.md) |
| **Array → String** | `joined=$(str_join "," "${MY_ARR[@]}")` | [`11-string.sh`](docs/11-string/str_join.md) |
| **File lines → Array** | `file_read_to_array "hosts.txt" "HOSTS" 1` | [`09-file.sh`](docs/09-file/file_read_to_array.md) |
| **Lower / Upper / Title** | `str_to_lower "ABC"` / `str_to_upper "abc"` / `str_capitalize "hello"` | [`11-string.sh`](docs/11-string/README.md) |
| **Slugify string** | `slug=$(str_slugify "My Release v1.2!")` | [`11-string.sh`](docs/11-string/str_slugify.md) |
| **JSON → YAML** | `yaml=$(json_to_yaml '{"a":1,"b":"two"}')` | [`14-jq.sh`](docs/14-jq/json_to_yaml.md) |
| **Pretty / Compact JSON** | `json_beautify "${raw}"` / `json_compact "${raw}"` | [`14-jq.sh`](docs/14-jq/README.md) |
| **Date format / Timezone** | `date_format "2026-11-20" "%d/%m/%Y"` / `timezone_convert "2026-11-20 10:00:00" "UTC" "Asia/Kolkata"` | [`08-datetime.sh`](docs/08-datetime/README.md) |
| **Seconds → Duration** | `format_duration 3725` *(outputs `1h 2m 5s`)* | [`08-datetime.sh`](docs/08-datetime/format_duration.md) |
| **JWT → JSON Claims** | `jwt_decode "${token}"` / `jwt_get_claim "${token}" ".sub"` | [`13-jwt.sh`](docs/13-jwt/README.md) |

---

## 6. Strings & Pattern Matching

```zsh
text="  Hello World  "
clean=$(str_trim "${text}")                        # "Hello World"
str_contains "${clean}" "World" && echo "Match!"   # substring check
str_starts_with "${clean}" "Hello" && echo "Starts"
str_ends_with "${clean}" "World" && echo "Ends"
replaced=$(str_replace "${clean}" "World" "Zsh")   # "Hello Zsh"
```

---

## 7. Control Flow & Loops (Quick Reference)

```zsh
# If / Elif / Else (use [[ ... ]] for strings/files, (( ... )) for numbers)
if [[ -f "./config.env" ]]; then
  echo "Config exists"
elif (( count > 10 )); then
  echo "Count is high"
else
  echo "Fallback"
fi

# Case statement
case "${APP_ENV}" in
  prod|production) echo "Production mode" ;;
  staging|qa)      echo "Pre-prod mode" ;;
  *)               echo "Local/Dev mode" ;;
esac
```

See [docs/97-loops.md](docs/97-loops.md) and [docs/98-control-statements.md](docs/98-control-statements.md) for complete copy-paste loop and conditional guides.

---

## 8. Files, Directories & Comparisons

```zsh
# Read, write, append
file_write "/tmp/out.txt" "line 1\nline 2"
file_append "/tmp/out.txt" "line 3"
content=$(file_read "/tmp/out.txt")

# Compare two files
file_equals "a.txt" "b.txt" && echo "Identical"
file_compare -u 5 -o "./logs/file_diff.md" "a.txt" "b.txt"

# Compare two directories (recursively, with diffs)
dir_compare --diff -o "./logs/dir_diff.md" "./dir_v1" "./dir_v2"

# Safe delete (skip prompt with --force)
file_delete "/tmp/out.txt" "--force"
dir_delete "/tmp/old_dir" "--force"
```

---

## 9. HTTP, Secrets Cache & Masking

```zsh
# Cache a JWT/secret so scripts don't re-login on every run
login_fn() { echo "my-fresh-jwt-token"; }
token=$(cache_get_or_set "payments/prod/jwt" 3600 login_fn)

# Never print raw secrets in logs
log_info "Using token: $(mask_token "${token}")"

# HTTP GET & POST (inline JSON or .json file)
resp=$(http_get "https://httpbin.org/get")
http_post "https://httpbin.org/post" '{"hello":"world"}'
http_post "https://httpbin.org/post" "./payload.json"
```

---

## 10. Git, Script Sequencing & Error Handling

```zsh
# Compare Git branches or commits
git_compare_branches --silent --output "./logs/branch_diff.md" "main" "feature"
git_compare_commits --diff -o "./logs/commit_diff.md" "HEAD~3" "HEAD"

# Run multiple scripts in order (sharing exported/global variables)
execute_scripts_sequence --source "./login.sh" "./verify.sh" "./update.sh"

# Auto-cleanup temp files on exit/error
tmp=$(mktemp)
register_temp_file "${tmp}"
[[ -n "${token}" ]] || error_exit "Missing auth token" 1
```

---

**More Resources:**
- [README.md](README.md) — Framework overview, setup, and module table
- [GLOSSARY.md](GLOSSARY.md) — Complete alphabetical/module index of every variable and function
- [docs/](docs) — Per-module and per-function documentation with all flags
- [examples/](examples) — Runnable example scripts for every module
