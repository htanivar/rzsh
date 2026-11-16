#!/usr/bin/env bash
#
# graphify-common.sh - shared helpers for the graphify toolkit (source, don't run)
#
# Provides: logging (console + per-run log file), exit-code constants, traps,
# locking, graph backup/validation, API-key discovery, prompts, script lookup.
#
# State (logs, backups, lock) lives OUTSIDE the repo so a rebuild can never
# delete it:  ${XDG_STATE_HOME:-~/.local/state}/graphify/<project>-<hash>/
#

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    echo "graphify-common.sh is a library; source it from another script." >&2
    exit 2
fi
if [[ -n "${_GFY_COMMON_LOADED:-}" ]]; then
    return 0
fi
_GFY_COMMON_LOADED=1

GFY_ORIG_PATH="$PATH"   # the user's real shell PATH, before we extend it
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.pyenv/shims:$PATH"

# ----------------------------------------------------------------------------
# Exit codes (stable, so wrappers/CI can react to them)
# ----------------------------------------------------------------------------
readonly EX_OK=0
readonly EX_FAIL=1         # generic / unknown failure
readonly EX_USAGE=2        # bad arguments, missing API key, bad config
readonly EX_INCOMPLETE=3   # extraction incomplete; existing graph kept intact
readonly EX_DEP=4          # missing dependency (graphify, python, packages)
readonly EX_LOCK=5         # another run is in progress

GFY_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GRAPHIFY_OUT="${GRAPHIFY_OUT:-graphify-out}"
GRAPH_FILE="$GRAPHIFY_OUT/graph.json"

GFY_STATE_DIR=""
GFY_LOG_DIR=""
GFY_BACKUP_DIR=""
GFY_RUN_LOG=""
GFY_LAST_BACKUP=""
GFY_LOCK_HELD=0
GFY_ASSUME_YES="${GFY_ASSUME_YES:-0}"
declare -a GFY_TMP_FILES=()

# ----------------------------------------------------------------------------
# Colours (stderr for log lines, stdout for banners/reports)
# ----------------------------------------------------------------------------
if [[ -t 2 && -z "${NO_COLOR:-}" ]]; then
    _E_RED=$'\033[0;31m'; _E_GREEN=$'\033[0;32m'; _E_YELLOW=$'\033[1;33m'
    _E_BLUE=$'\033[0;34m'; _E_NC=$'\033[0m'
else
    _E_RED=""; _E_GREEN=""; _E_YELLOW=""; _E_BLUE=""; _E_NC=""
fi
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
    RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'
    BLUE=$'\033[0;34m'; PURPLE=$'\033[0;35m'; CYAN=$'\033[0;36m'
    BOLD=$'\033[1m'; NC=$'\033[0m'
else
    RED=""; GREEN=""; YELLOW=""; BLUE=""; PURPLE=""; CYAN=""; BOLD=""; NC=""
fi

# ----------------------------------------------------------------------------
# Logging
# ----------------------------------------------------------------------------
gfy_logfile_write() {
    [[ -n "$GFY_RUN_LOG" ]] || return 0
    printf '[%s] [%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" "$2" >> "$GFY_RUN_LOG" 2>/dev/null || true
}
info()  { printf '%s[INFO]%s %s\n'    "$_E_GREEN"  "$_E_NC" "$*" >&2; gfy_logfile_write INFO  "$*"; }
warn()  { printf '%s[WARN]%s %s\n'    "$_E_YELLOW" "$_E_NC" "$*" >&2; gfy_logfile_write WARN  "$*"; }
err()   { printf '%s[ERROR]%s %s\n'   "$_E_RED"    "$_E_NC" "$*" >&2; gfy_logfile_write ERROR "$*"; }
step()  { printf '%s[STEP]%s %s\n'    "$_E_BLUE"   "$_E_NC" "$*" >&2; gfy_logfile_write STEP  "$*"; }
die()   { local code=$1; shift; err "$*"; exit "$code"; }

# Append a captured command log (ANSI/CR stripped) to the run log.
# usage: gfy_append_log <file> [max_lines]
gfy_append_log() {
    [[ -n "$GFY_RUN_LOG" && -f "$1" ]] || return 0
    {
        printf -- '----- captured output: %s -----\n' "$(basename "$1")"
        tr '\r' '\n' < "$1" | sed -E 's/\x1b\[[0-9;?]*[A-Za-z]//g' | tail -n "${2:-2000}"
        printf -- '----- end -----\n'
    } >> "$GFY_RUN_LOG" 2>/dev/null || true
}

# ----------------------------------------------------------------------------
# Init, traps, temp files, locking
# ----------------------------------------------------------------------------
# usage: gfy_init <script-name>
gfy_init() {
    local name="${1:-graphify}" key
    key="$(basename "$PWD")-$(printf '%s' "$PWD" | cksum | cut -d' ' -f1)"
    GFY_STATE_DIR="${GFY_STATE_DIR_OVERRIDE:-${XDG_STATE_HOME:-$HOME/.local/state}/graphify/$key}"
    GFY_LOG_DIR="$GFY_STATE_DIR/logs"
    GFY_BACKUP_DIR="$GFY_STATE_DIR/backups"

    if mkdir -p "$GFY_LOG_DIR" "$GFY_BACKUP_DIR" 2>/dev/null; then
        GFY_RUN_LOG="$GFY_LOG_DIR/$name-$(date +%Y%m%d-%H%M%S)-$$.log"
        if ! : > "$GFY_RUN_LOG" 2>/dev/null; then GFY_RUN_LOG=""; fi
        # keep the 30 most recent logs
        ls -1t "$GFY_LOG_DIR"/*.log 2>/dev/null | tail -n +31 | xargs -r rm -f -- 2>/dev/null || true
    else
        GFY_RUN_LOG=""
        GFY_BACKUP_DIR="${TMPDIR:-/tmp}/graphify-backups-$$"
        mkdir -p "$GFY_BACKUP_DIR" 2>/dev/null || true
    fi

    gfy_logfile_write INFO "start: $name  cwd=$PWD  args=${GFY_ARGS:-}"
    trap '_gfy_on_err "$LINENO" "$?"' ERR
    trap '_gfy_on_exit' EXIT
    trap '_gfy_on_signal INT' INT
    trap '_gfy_on_signal TERM' TERM
}

_gfy_on_err() { gfy_logfile_write TRACE "line $1: '${BASH_COMMAND}' exited with $2"; }

_gfy_on_signal() {
    printf '\n' >&2
    warn "Interrupted ($1)."
    exit 130
}

_gfy_on_exit() {
    local rc=$?
    local f
    for f in ${GFY_TMP_FILES[@]+"${GFY_TMP_FILES[@]}"}; do rm -f -- "$f" 2>/dev/null || true; done
    if [[ "$GFY_LOCK_HELD" == 1 && -n "$GFY_STATE_DIR" ]]; then
        rm -rf -- "$GFY_STATE_DIR/lock" 2>/dev/null || true
    fi
    gfy_logfile_write INFO "exit code $rc"
    if (( rc != 0 && rc != 130 )) && [[ -n "$GFY_RUN_LOG" ]]; then
        printf '%s[LOG]%s  Details: %s\n' "$_E_BLUE" "$_E_NC" "$GFY_RUN_LOG" >&2
    fi
}

# usage: gfy_mktemp VARNAME   (file is removed automatically on exit)
gfy_mktemp() {
    local _t
    _t=$(mktemp "${TMPDIR:-/tmp}/graphify.XXXXXX") || return 1
    GFY_TMP_FILES+=("$_t")
    printf -v "$1" '%s' "$_t"
}

gfy_acquire_lock() {
    [[ "$GFY_LOCK_HELD" == 1 ]] && return 0
    [[ -n "$GFY_STATE_DIR" ]] || return 0
    local lock="$GFY_STATE_DIR/lock" pid
    if mkdir "$lock" 2>/dev/null; then
        echo "$$" > "$lock/pid"; GFY_LOCK_HELD=1; return 0
    fi
    pid=$(cat "$lock/pid" 2>/dev/null || true)
    if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
        err "Another graphify run is already active for this project (pid $pid)."
        return "$EX_LOCK"
    fi
    warn "Removing stale lock (pid ${pid:-unknown} is not running)."
    rm -rf -- "$lock"
    if mkdir "$lock" 2>/dev/null; then
        echo "$$" > "$lock/pid"; GFY_LOCK_HELD=1; return 0
    fi
    err "Could not acquire lock at $lock"
    return "$EX_LOCK"
}

# ----------------------------------------------------------------------------
# Prompts
# ----------------------------------------------------------------------------
# usage: gfy_confirm "Question?" [y|n default] [strict]
# 'strict' ignores --yes (use for destructive/overwriting actions).
# With no TTY and no --yes the answer is always 'no'.
gfy_confirm() {
    local prompt="$1" def="${2:-n}" strict="${3:-}" reply hint="[y/N]"
    [[ "$def" == y ]] && hint="[Y/n]"
    if [[ "$GFY_ASSUME_YES" == 1 && "$strict" != strict ]]; then return 0; fi
    if [[ ! -t 0 ]]; then
        return 1   # unattended and no --yes: never assume consent
    fi
    read -r -p "$prompt $hint: " reply || return 1
    reply="${reply:-$def}"
    [[ "$reply" =~ ^[Yy] ]]
}

# ----------------------------------------------------------------------------
# Helpers: scripts, graphify binary
# ----------------------------------------------------------------------------
gfy_find_script() {
    local name="$1" c
    for c in "$GFY_LIB_DIR/$name" "scripts/lib/graphify/$name" "./$name"; do
        if [[ -f "$c" ]]; then printf '%s\n' "$c"; return 0; fi
    done
    return 1
}

gfy_ensure_graphify() {
    if command -v graphify >/dev/null 2>&1; then return 0; fi
    warn "'graphify' not found in PATH."
    local installer
    if ! installer=$(gfy_find_script install-graphify.sh); then
        err "install-graphify.sh not found. Install manually: uv tool install \"graphifyy[gemini,sql]\""
        return "$EX_DEP"
    fi
    step "Launching installer: $installer"
    local -a args=()
    [[ "$GFY_ASSUME_YES" == 1 ]] && args+=(--yes)
    if ! bash "$installer" ${args[@]+"${args[@]}"}; then
        err "Graphify installation failed or was cancelled."
        return "$EX_DEP"
    fi
    hash -r 2>/dev/null || true
    if ! command -v graphify >/dev/null 2>&1; then
        err "graphify still not on PATH after install. Ensure ~/.local/bin is in PATH."
        return "$EX_DEP"
    fi
}

# ----------------------------------------------------------------------------
# Graph helpers
# ----------------------------------------------------------------------------
gfy_json_valid() {
    local f="$1"
    [[ -s "$f" ]] || return 1
    if command -v jq >/dev/null 2>&1; then
        jq -e 'type == "object"' "$f" >/dev/null 2>&1
    elif command -v python3 >/dev/null 2>&1; then
        python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$f" >/dev/null 2>&1
    else
        return 0   # cannot validate; assume ok
    fi
}

# usage: gfy_graph_metric nodes|edges|communities [file]   -> number or "?"
gfy_graph_metric() {
    local key="$1" f="${2:-$GRAPH_FILE}" expr
    [[ -f "$f" ]] || { echo "?"; return 0; }
    if command -v jq >/dev/null 2>&1; then
        case "$key" in
            edges) expr='(.edges // .links // []) | length' ;;
            *)     expr="(.${key} // []) | length" ;;
        esac
        jq -r "$expr" "$f" 2>/dev/null || echo "?"
    elif command -v python3 >/dev/null 2>&1; then
        python3 - "$f" "$key" 2>/dev/null <<'PY' || echo "?"
import json, sys
d = json.load(open(sys.argv[1])); k = sys.argv[2]
v = (d.get("edges") or d.get("links") or []) if k == "edges" else (d.get(k) or [])
print(len(v))
PY
    else
        echo "?"
    fi
}

gfy_backup_graph() {
    GFY_LAST_BACKUP=""
    [[ -f "$GRAPH_FILE" ]] || return 0
    if ! gfy_json_valid "$GRAPH_FILE"; then
        warn "Existing $GRAPH_FILE is not valid JSON; backing it up anyway."
    fi
    local dst="$GFY_BACKUP_DIR/graph-$(date +%Y%m%d-%H%M%S).json"
    if cp -p "$GRAPH_FILE" "$dst" 2>/dev/null; then
        GFY_LAST_BACKUP="$dst"
        info "Backed up current graph -> $dst"
        ls -1t "$GFY_BACKUP_DIR"/graph-*.json 2>/dev/null | tail -n +6 | xargs -r rm -f -- 2>/dev/null || true
    else
        warn "Could not back up $GRAPH_FILE (continuing without a backup)."
    fi
}

# Restore backup only if the live graph is missing/corrupt.
gfy_restore_if_broken() {
    [[ -n "$GFY_LAST_BACKUP" && -f "$GFY_LAST_BACKUP" ]] || return 0
    if [[ ! -f "$GRAPH_FILE" ]] || ! gfy_json_valid "$GRAPH_FILE"; then
        warn "Graph file missing or corrupt after run; restoring backup."
        mkdir -p "$GRAPHIFY_OUT"
        cp -p "$GFY_LAST_BACKUP" "$GRAPH_FILE" && info "Restored $GRAPH_FILE from backup."
    fi
}

gfy_show_stats() {
    if [[ ! -f "$GRAPH_FILE" ]]; then
        warn "No graph found at $GRAPH_FILE. Run an update first."
        return 0
    fi
    local size nodes edges comms mtime
    if command -v numfmt >/dev/null 2>&1; then size=$(wc -c < "$GRAPH_FILE" | numfmt --to=si)
    else size="$(wc -c < "$GRAPH_FILE") bytes"; fi
    nodes=$(gfy_graph_metric nodes); edges=$(gfy_graph_metric edges); comms=$(gfy_graph_metric communities)
    mtime=$(date -r "$GRAPH_FILE" '+%Y-%m-%d %H:%M' 2>/dev/null || echo "?")
    echo ""
    echo -e "${BOLD}${BLUE}📊 Current Knowledge Graph Stats${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "📁 Graph File:   ${BOLD}$GRAPH_FILE${NC} ($size, updated $mtime)"
    echo -e "🟢 Nodes:        ${BOLD}$nodes${NC}"
    echo -e "🔗 Edges:        ${BOLD}$edges${NC}"
    echo -e "🌐 Communities:  ${BOLD}$comms${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# ----------------------------------------------------------------------------
# Gemini API key discovery
# ----------------------------------------------------------------------------
_gfy_read_env_key() {
    local f="$1" line
    [[ -r "$f" ]] || return 1
    line=$(grep -E '^[[:space:]]*(export[[:space:]]+)?(GEMINI_API_KEY|GOOGLE_API_KEY)=' "$f" 2>/dev/null | head -n 1 || true)
    [[ -n "$line" ]] || return 1
    line="${line#*=}"
    line="${line%$'\r'}"
    line=$(printf '%s' "$line" | sed -E "s/^[[:space:]\"']+//; s/[[:space:]\"']+\$//")
    [[ -n "$line" ]] || return 1
    printf '%s' "$line"
}

gfy_ensure_api_key() {
    if [[ -n "${GEMINI_API_KEY:-}" ]]; then return 0; fi
    if [[ -n "${GOOGLE_API_KEY:-}" ]]; then
        export GEMINI_API_KEY="$GOOGLE_API_KEY"
        return 0
    fi
    local f key
    for f in ".env" "$HOME/.env"; do
        if key=$(_gfy_read_env_key "$f"); then
            export GEMINI_API_KEY="$key"
            info "Loaded Gemini API key from $f"
            return 0
        fi
    done

    warn "GEMINI_API_KEY / GOOGLE_API_KEY is not set (env, ./.env, ~/.env)."
    echo "         Get a key at: https://aistudio.google.com/app/apikey" >&2
    if [[ -t 0 ]]; then
        local input_key=""
        read -rsp "Enter your Gemini API key (hidden, blank to abort): " input_key || true
        echo "" >&2
        if [[ -n "$input_key" ]]; then
            export GEMINI_API_KEY="$input_key"
            if gfy_confirm "Save this key to ./.env for future runs?" n strict; then
                ( umask 077; printf 'GEMINI_API_KEY="%s"\n' "$input_key" >> .env )
                chmod 600 .env 2>/dev/null || true
                info "Saved key to .env (mode 600)"
                if [[ -f .gitignore ]]; then
                    grep -qE '^\.env$' .gitignore || { printf '\n.env\n' >> .gitignore; info "Added .env to .gitignore"; }
                else
                    printf '.env\n' > .gitignore; info "Created .gitignore with .env"
                fi
            fi
            return 0
        fi
    fi
    err "A Gemini API key is required. Export GEMINI_API_KEY or put it in ./.env"
    return "$EX_USAGE"
}

# usage: gfy_countdown <seconds> <label>
gfy_countdown() {
    local secs="$1" label="${2:-Resuming}" w
    if [[ -t 2 ]]; then
        for ((w = secs; w > 0; w--)); do
            printf '\r%s⏳ %s in %3ss...%s ' "$_E_YELLOW" "$label" "$w" "$_E_NC" >&2
            sleep 1
        done
        printf '\r\033[K' >&2
    else
        info "$label in ${secs}s (sleeping)"
        sleep "$secs"
    fi
}
