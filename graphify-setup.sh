#!/usr/bin/env bash
#
# graphify-setup.sh - Build / update / watch a Graphify knowledge graph for ONE repo
#                     (standalone: no other scripts required)
#
# Usage:
#   graphify-setup.sh [-C DIR] [OPTIONS] [ACTION]
#
# Actions:
#   (none)                Interactive menu
#   -u, --update          Incremental update
#   -r, --rebuild         Full rebuild (safe: backs up, never clobbers a larger graph)
#   -w, --watch           Live watch mode
#   -s, --stats           Graph statistics
#   --mcp                 Configure Antigravity + MCP for this repo
#   --doctor              Environment diagnostics
#   --install [--force]   Install / reinstall graphify (uv -> pipx -> pip)
#
# Options:
#   -C, --dir DIR         Repo to build the graph for (default: current directory)
#   -y, --yes             Assume yes to (non-destructive) prompts
#   --code-only           Local AST only (no LLM, no API key); combine with -u / -r
#   --allow-partial       If extraction stays incomplete, overwrite the graph anyway
#                         (a backup is always taken first)
#   --budgets "A B C"     Token-budget ladder used when files are omitted
#                         (default: "16000 8000 4000"; env GFY_TOKEN_BUDGETS)
#   --backend NAME        Extraction backend (default: gemini; env GFY_BACKEND)
#
# Output:  <DIR>/graphify-out/graph.json
# Logs:    ~/.local/state/graphify/<repo>-<hash>/logs/    (last 30 runs)
# Backups: ~/.local/state/graphify/<repo>-<hash>/backups/ (last 5 graphs)
#
# Exit codes: 0 ok | 1 failure | 2 usage/API key | 3 incomplete (existing graph kept)
#             4 missing dependency | 5 another run active | 130 interrupted
#

set -Eeuo pipefail

GFY_ORIG_PATH="$PATH"   # the user's real shell PATH, before we extend it
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.pyenv/shims:$PATH"

# ============================================================================
# Constants & configuration
# ============================================================================
readonly EX_OK=0
readonly EX_FAIL=1         # generic / unknown failure
readonly EX_USAGE=2        # bad arguments, missing API key, bad config
readonly EX_INCOMPLETE=3   # extraction incomplete; existing graph kept intact
readonly EX_DEP=4          # missing dependency (graphify, python, packages)
readonly EX_LOCK=5         # another run is in progress

GFY_SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
GRAPHIFY_OUT="${GRAPHIFY_OUT:-graphify-out}"
GRAPH_FILE="$GRAPHIFY_OUT/graph.json"

PROJECT_DIR="."
BACKEND="${GFY_BACKEND:-gemini}"
GFY_MAX_ATTEMPTS="${GFY_MAX_ATTEMPTS:-8}"
GFY_TOKEN_BUDGETS="${GFY_TOKEN_BUDGETS:-16000 8000 4000}"
GFY_MAX_WATCH_FAILURES="${GFY_MAX_WATCH_FAILURES:-5}"
GFY_ASSUME_YES="${GFY_ASSUME_YES:-0}"
ALLOW_PARTIAL=0
CODE_ONLY=0                # 1 = local AST only (graphify --code-only), no API key needed
declare -a EXTRACT_ARGS=()
MCP_CONFIG_DIR="$HOME/.gemini/antigravity"
MCP_CONFIG_FILE="$MCP_CONFIG_DIR/mcp_config.json"
# Fallback ladder: full extras -> gemini only -> bare package (PyPI name has two y's)
declare -a GFY_PKG_SPECS=("graphifyy[gemini,sql]" "graphifyy[gemini]" "graphifyy")

GFY_STATE_DIR=""
GFY_LOG_DIR=""
GFY_BACKUP_DIR=""
GFY_RUN_LOG=""
GFY_LAST_BACKUP=""
GFY_LOCK_HELD=0
_EXTRACT_HELP=""
INCOMPLETE_ACTION=""
declare -a GFY_TMP_FILES=()

# ============================================================================
# Colours (stderr for log lines, stdout for banners/reports)
# ============================================================================
if [[ -t 2 && -z "${NO_COLOR:-}" ]]; then
    _E_RED=$'\033[0;31m'; _E_GREEN=$'\033[0;32m'; _E_YELLOW=$'\033[1;33m'
    _E_BLUE=$'\033[0;34m'; _E_NC=$'\033[0m'
else
    _E_RED=""; _E_GREEN=""; _E_YELLOW=""; _E_BLUE=""; _E_NC=""
fi
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
    RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'
    BLUE=$'\033[0;34m'; CYAN=$'\033[0;36m'; BOLD=$'\033[1m'; NC=$'\033[0m'
else
    RED=""; GREEN=""; YELLOW=""; BLUE=""; CYAN=""; BOLD=""; NC=""
fi

# ============================================================================
# Logging
# ============================================================================
gfy_logfile_write() {
    [[ -n "$GFY_RUN_LOG" ]] || return 0
    printf '[%s] [%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" "$2" >> "$GFY_RUN_LOG" 2>/dev/null || true
}
info()  { printf '%s[INFO]%s %s\n'  "$_E_GREEN"  "$_E_NC" "$*" >&2; gfy_logfile_write INFO  "$*"; }
warn()  { printf '%s[WARN]%s %s\n'  "$_E_YELLOW" "$_E_NC" "$*" >&2; gfy_logfile_write WARN  "$*"; }
err()   { printf '%s[ERROR]%s %s\n' "$_E_RED"    "$_E_NC" "$*" >&2; gfy_logfile_write ERROR "$*"; }
step()  { printf '%s[STEP]%s %s\n'  "$_E_BLUE"   "$_E_NC" "$*" >&2; gfy_logfile_write STEP  "$*"; }
die()   { local code=$1; shift; err "$*"; exit "$code"; }

# Append a captured command log (ANSI/CR stripped) to the run log.
gfy_append_log() {
    [[ -n "$GFY_RUN_LOG" && -f "$1" ]] || return 0
    {
        printf -- '----- captured output: %s -----\n' "$(basename "$1")"
        tr '\r' '\n' < "$1" | sed -E 's/\x1b\[[0-9;?]*[A-Za-z]//g' | tail -n "${2:-2000}"
        printf -- '----- end -----\n'
    } >> "$GFY_RUN_LOG" 2>/dev/null || true
}

# ============================================================================
# Init, traps, temp files, locking  (state is keyed by the repo's absolute path)
# ============================================================================
gfy_init() {
    local name="${1:-graphify}" key
    key="$(basename "$PWD")-$(printf '%s' "$PWD" | cksum | cut -d' ' -f1)"
    GFY_STATE_DIR="${GFY_STATE_DIR_OVERRIDE:-${XDG_STATE_HOME:-$HOME/.local/state}/graphify/$key}"
    GFY_LOG_DIR="$GFY_STATE_DIR/logs"
    GFY_BACKUP_DIR="$GFY_STATE_DIR/backups"

    if mkdir -p "$GFY_LOG_DIR" "$GFY_BACKUP_DIR" 2>/dev/null; then
        GFY_RUN_LOG="$GFY_LOG_DIR/$name-$(date +%Y%m%d-%H%M%S)-$$.log"
        if ! : > "$GFY_RUN_LOG" 2>/dev/null; then GFY_RUN_LOG=""; fi
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
    local rc=$? f
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
        err "Another graphify run is already active for this repo (pid $pid)."
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

# ============================================================================
# Prompts
# ============================================================================
# usage: gfy_confirm "Question?" [y|n default] [strict]
# 'strict' ignores --yes (use for destructive/overwriting actions).
# With no TTY and no --yes the answer is always 'no'.
gfy_confirm() {
    local prompt="$1" def="${2:-n}" strict="${3:-}" reply hint="[y/N]"
    [[ "$def" == y ]] && hint="[Y/n]"
    if [[ "$GFY_ASSUME_YES" == 1 && "$strict" != strict ]]; then return 0; fi
    [[ -t 0 ]] || return 1
    read -r -p "$prompt $hint: " reply || return 1
    reply="${reply:-$def}"
    [[ "$reply" =~ ^[Yy] ]]
}

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

# ============================================================================
# Built-in installer (replaces install-graphify.sh)
# ============================================================================
# usage: gfy_install_graphify [force]   -> tries uv, then pipx, then pip --user
gfy_install_graphify() {
    local force="${1:-}" s
    if [[ "$force" != force ]] && command -v graphify >/dev/null 2>&1; then
        info "✅ graphify already installed: $(command -v graphify) (use --install --force to refresh extras)"
        return 0
    fi
    command -v python3 >/dev/null 2>&1 || { err "python3 not found. Install Python 3.9+ first."; return "$EX_DEP"; }

    local installed=""
    if command -v uv >/dev/null 2>&1; then
        for s in "${GFY_PKG_SPECS[@]}"; do
            info "uv tool install \"$s\" --force"
            if uv tool install "$s" --force; then installed="$s"; break; fi
            warn "Failed with '$s'; trying a smaller spec."
        done
    elif command -v pipx >/dev/null 2>&1; then
        for s in "${GFY_PKG_SPECS[@]}"; do
            info "pipx install \"$s\" --force"
            if pipx install "$s" --force; then installed="$s"; break; fi
            warn "Failed with '$s'; trying a smaller spec."
        done
    elif python3 -m pip --version >/dev/null 2>&1; then
        for s in "${GFY_PKG_SPECS[@]}"; do
            info "python3 -m pip install --user \"$s\""
            if python3 -m pip install --user "$s"; then installed="$s"; break; fi
            warn "Failed with '$s'; trying a smaller spec."
        done
    else
        err "No installer found (uv, pipx or pip). Install uv: https://docs.astral.sh/uv/"
        return "$EX_DEP"
    fi

    [[ -n "$installed" ]] || { err "graphify installation failed."; return "$EX_DEP"; }
    hash -r 2>/dev/null || true
    _EXTRACT_HELP=""
    if ! command -v graphify >/dev/null 2>&1; then
        err "graphify installed but not on PATH. Add ~/.local/bin to PATH."
        return "$EX_DEP"
    fi
    info "🎉 graphify installed: $(command -v graphify) (spec: $installed)"
    case "$installed" in
        "graphifyy[gemini,sql]") ;;
        "graphifyy[gemini]") warn "SQL extra could not be installed: .sql files won't be parsed." ;;
        *) warn "Installed WITHOUT extras: the Gemini backend will not work until extras install." ;;
    esac
    if [[ ":$GFY_ORIG_PATH:" != *":$HOME/.local/bin:"* ]]; then
        warn "~/.local/bin is not in your shell's PATH. Add: export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
}

gfy_ensure_graphify() {
    command -v graphify >/dev/null 2>&1 && return 0
    warn "'graphify' not found in PATH."
    if ! gfy_confirm "Install graphify now (uv/pipx/pip)?" y; then
        err "graphify is required. Install: uv tool install \"graphifyy[gemini,sql]\""
        return "$EX_DEP"
    fi
    gfy_install_graphify
}

# ============================================================================
# Graph helpers
# ============================================================================
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
            edges)       expr='(.edges // .links // []) | length' ;;
            # graphify v0.9+ stores the community id on each node, not as a top-level list
            communities) expr='if (.communities | type) == "array" then (.communities | length)
                               else ([.nodes[]?.community | select(. != null)] | unique | length) end' ;;
            *)           expr="(.${key} // []) | length" ;;
        esac
        jq -r "$expr" "$f" 2>/dev/null || echo "?"
    elif command -v python3 >/dev/null 2>&1; then
        python3 - "$f" "$key" 2>/dev/null <<'PY' || echo "?"
import json, sys
d = json.load(open(sys.argv[1])); k = sys.argv[2]
if k == "edges":
    v = d.get("edges") or d.get("links") or []
elif k == "communities" and not isinstance(d.get("communities"), list):
    v = {n.get("community") for n in d.get("nodes", []) if n.get("community") is not None}
else:
    v = d.get(k) or []
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
        warn "No graph found at $PWD/$GRAPH_FILE. Run --update first."
        return 0
    fi
    local size nodes edges comms mtime
    if command -v numfmt >/dev/null 2>&1; then size=$(wc -c < "$GRAPH_FILE" | numfmt --to=si)
    else size="$(wc -c < "$GRAPH_FILE") bytes"; fi
    nodes=$(gfy_graph_metric nodes); edges=$(gfy_graph_metric edges); comms=$(gfy_graph_metric communities)
    mtime=$(date -r "$GRAPH_FILE" '+%Y-%m-%d %H:%M' 2>/dev/null || echo "?")
    echo ""
    echo -e "${BOLD}${BLUE}📊 Knowledge Graph Stats: $(basename "$PWD")${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "📁 Graph File:   ${BOLD}$PWD/$GRAPH_FILE${NC} ($size, updated $mtime)"
    echo -e "🟢 Nodes:        ${BOLD}$nodes${NC}"
    echo -e "🔗 Edges:        ${BOLD}$edges${NC}"
    echo -e "🌐 Communities:  ${BOLD}$comms${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# ============================================================================
# Gemini API key discovery (env -> ./.env -> ~/.env -> prompt)
# ============================================================================
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
    [[ "$CODE_ONLY" == 1 ]] && return 0
    [[ "$BACKEND" == gemini ]] || return 0
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

# ============================================================================
# graphify capability detection (don't pass flags the installed version lacks)
# ============================================================================
# graphify (v0.9+) only documents extract flags in the top-level `graphify --help`,
# so take the "extract <path>" section from there; fall back to `extract --help`.
_load_extract_help() {
    [[ -n "$_EXTRACT_HELP" ]] && return 0
    _EXTRACT_HELP=$(graphify --help 2>&1 | awk '
        /^  extract <path>/ { on = 1; next }
        on && /^  [a-z]/    { exit }
        on                  { print }' || true)
    if [[ -z "$_EXTRACT_HELP" ]]; then
        _EXTRACT_HELP=$(graphify extract --help 2>&1 || true)
    fi
}

extract_supports() {
    local flag="$1"
    _load_extract_help
    [[ -z "$_EXTRACT_HELP" ]] && return 0   # can't tell; be optimistic
    grep -qE -- "(^|[[:space:],])${flag}([[:space:]=,]|$)" <<<"$_EXTRACT_HELP"
}

# usage: build_args PATH [inc|force]   -> sets the global EXTRACT_ARGS array
# Incremental is graphify's default; --incremental is only passed to versions that list it.
build_args() {
    EXTRACT_ARGS=("$1" --backend "$BACKEND")
    if [[ "$CODE_ONLY" == 1 ]]; then EXTRACT_ARGS+=(--code-only); fi
    case "${2:-inc}" in
        force) EXTRACT_ARGS+=(--force) ;;
        inc)   if extract_supports --incremental; then EXTRACT_ARGS+=(--incremental); fi ;;
    esac
}

# ============================================================================
# Failure classification
# ============================================================================
# Prints one of: missing_dep auth rate_limit incomplete transient unknown
classify_failure() {
    local log="$1"
    if grep -qiE "package is required|requires the .* package|tree_sitter_sql not installed|No module named" "$log"; then
        echo missing_dep
    elif grep -qiE "PERMISSION_DENIED|UNAUTHENTICATED|API key (not valid|invalid)|HTTP 40[13]|status(_code)?[ :=]+40[13]" "$log"; then
        echo auth
    elif grep -qiE "\b429\b|RESOURCE_EXHAUSTED|Too Many Requests|rate.?limit|exceeded.*quota" "$log"; then
        echo rate_limit
    elif grep -qiE "extraction (was )?incomplete|Refusing to overwrite|dispatched file\(s\) produced no nodes" "$log"; then
        echo incomplete
    elif grep -qiE "timed? ?out|Connection (reset|refused|aborted|error)|HTTP 50[234]|Name or service not known|SSLError|Temporary failure" "$log"; then
        echo transient
    else
        echo unknown
    fi
}

# Seconds suggested by the API (rounded up) or 0 if none found.
parse_retry_delay() {
    local log="$1" v
    v=$(grep -ioE 'retry ?delay"?[^0-9]{0,6}[0-9]+(\.[0-9]+)?|retry (in|after) [0-9]+(\.[0-9]+)?' "$log" 2>/dev/null \
        | head -n 1 | grep -oE '[0-9]+(\.[0-9]+)?$' || true)
    if [[ -n "$v" ]]; then
        awk -v v="$v" 'BEGIN { printf "%d", (v == int(v)) ? v : int(v) + 1 }'
    else
        echo 0
    fi
}

summarize_incomplete() {
    local log="$1" line
    warn "Extraction finished but the graph is incomplete."
    line=$(grep -E "dispatched file\(s\) produced no nodes" "$log" | head -n 1 || true)
    if [[ -n "$line" ]]; then warn "  ${line#*WARNING: }"; fi
    line=$(grep -E "saved semantic node\(s\) are missing" "$log" | head -n 1 || true)
    if [[ -n "$line" ]]; then
        warn "  Shrink guard fired: the new graph would lose existing semantic nodes."
        warn "  (${line#*missing from the ask graph: })"
    fi
}

# Decide what to do when extraction stays incomplete after the token-budget ladder.
# Sets INCOMPLETE_ACTION to: keep | incremental | partial
resolve_incomplete() {
    local can_incremental="$1" choice=1
    INCOMPLETE_ACTION=keep

    if [[ "$ALLOW_PARTIAL" == 1 ]]; then
        warn "--allow-partial given: the incomplete graph will overwrite the current one (backup: ${GFY_LAST_BACKUP:-none})."
        INCOMPLETE_ACTION=partial
        return 0
    fi
    if [[ ! -t 0 ]]; then
        warn "Non-interactive: keeping the existing graph untouched."
        return 0
    fi

    echo "" >&2
    echo -e "${BOLD}The model kept omitting some files. What now?${NC}" >&2
    echo "  1) Keep the existing graph untouched (safe)  [default]" >&2
    if [[ "$can_incremental" == 1 ]]; then
        echo "  2) Run an incremental update instead (reuses cache, retries only missing files)" >&2
    fi
    echo "  3) Overwrite with the partial graph (current graph backed up first)" >&2
    read -r -p "Choice [1]: " choice || choice=1
    case "${choice:-1}" in
        2)
            if [[ "$can_incremental" == 1 ]]; then INCOMPLETE_ACTION=incremental; fi ;;
        3)
            if gfy_confirm "This replaces the larger graph with a smaller one. Really overwrite?" n strict; then
                INCOMPLETE_ACTION=partial
            fi ;;
    esac
}

# ============================================================================
# Extraction engine: backup -> run -> classify -> targeted recovery
# ============================================================================
# usage: run_extraction <graphify extract args...>
run_extraction() {
    gfy_ensure_graphify || return $?
    gfy_ensure_api_key  || return $?
    gfy_acquire_lock    || return $?

    local -a base=("$@") budget_args=() partial_args=() budgets=()
    local attempt=0 budget_i=0 rc cls log wait deps_offered=0 partial_used=0
    local before_nodes
    read -ra budgets <<<"$GFY_TOKEN_BUDGETS"

    gfy_backup_graph
    before_nodes=$(gfy_graph_metric nodes)

    while (( attempt < GFY_MAX_ATTEMPTS )); do
        attempt=$((attempt + 1))
        gfy_mktemp log
        local -a cmd=(graphify extract "${base[@]}" ${budget_args[@]+"${budget_args[@]}"} ${partial_args[@]+"${partial_args[@]}"})
        info "Attempt $attempt/$GFY_MAX_ATTEMPTS: ${cmd[*]}"

        rc=0
        "${cmd[@]}" 2>&1 | tee "$log" || rc=${PIPESTATUS[0]}
        gfy_append_log "$log"

        # ---- success ------------------------------------------------------
        if (( rc == 0 )); then
            gfy_restore_if_broken
            if [[ ! -f "$GRAPH_FILE" ]] || ! gfy_json_valid "$GRAPH_FILE"; then
                err "graphify exited 0 but $GRAPH_FILE is missing or invalid."
                return "$EX_FAIL"
            fi
            local nwarn
            nwarn=$(grep -ciE "^\[graphify\] WARNING|warning:" "$log" || true)
            if (( nwarn > 0 )); then
                warn "Completed with $nwarn warning(s) (e.g. unparsable files). Review: $GFY_RUN_LOG"
            fi
            info "✅ Extraction succeeded: nodes ${before_nodes} -> $(gfy_graph_metric nodes), edges $(gfy_graph_metric edges)"
            return 0
        fi

        cls=$(classify_failure "$log")
        warn "Attempt $attempt failed (exit $rc, cause: $cls)"

        case "$cls" in
            missing_dep)
                if (( deps_offered )); then
                    err "Dependencies still missing after install attempt."; return "$EX_DEP"
                fi
                deps_offered=1
                warn "A required Python package is missing (e.g. 'openai' for Gemini, 'tree_sitter_sql')."
                if gfy_confirm "Reinstall graphify with extras now?" y; then
                    if gfy_install_graphify force; then
                        info "Retrying extraction..."
                        continue
                    fi
                    err "Reinstall failed."
                fi
                echo "  Manual fix: uv tool install \"graphifyy[gemini,sql]\" --force" >&2
                return "$EX_DEP"
                ;;

            auth)
                err "Gemini rejected the API key (invalid, expired, or lacks permission)."
                err "Check GEMINI_API_KEY / .env, then retry."
                return "$EX_USAGE"
                ;;

            rate_limit)
                wait=$(parse_retry_delay "$log")
                if (( wait == 0 )); then wait=$((30 * attempt)); fi
                wait=$((wait + 5))
                if (( wait > 300 )); then wait=300; fi
                warn "Gemini rate limit / quota hit. Waiting ${wait}s before attempt $((attempt + 1))."
                gfy_countdown "$wait" "Resuming"
                ;;

            transient)
                wait=$((10 * attempt))
                warn "Transient network/server error. Waiting ${wait}s."
                gfy_countdown "$wait" "Retrying"
                ;;

            incomplete)
                summarize_incomplete "$log"
                if (( partial_used )); then
                    err "Still incomplete even with --allow-partial."; return "$EX_FAIL"
                fi
                # 1) Shrink semantic chunks so the model addresses every file.
                if (( budget_i < ${#budgets[@]} )) && extract_supports --token-budget; then
                    budget_args=(--token-budget "${budgets[$budget_i]}")
                    budget_i=$((budget_i + 1))
                    info "Retrying with smaller semantic chunks: --token-budget ${budget_args[1]}"
                    continue
                fi
                # 2) Ladder exhausted: let the user decide, never clobber silently.
                local can_inc=0 a
                for a in "${base[@]}"; do [[ "$a" == --force ]] && can_inc=1; done
                resolve_incomplete "$can_inc"
                case "$INCOMPLETE_ACTION" in
                    keep)
                        warn "Existing graph kept as-is ($(gfy_graph_metric nodes) nodes)."
                        warn "Next steps: run --update (reuses the semantic cache and retries"
                        warn "only the omitted files), try --budgets \"2000 1000\", or --allow-partial."
                        return "$EX_INCOMPLETE"
                        ;;
                    incremental)
                        local -a inc=() x
                        for x in "${base[@]}"; do [[ "$x" == --force ]] || inc+=("$x"); done
                        if extract_supports --incremental; then inc+=(--incremental); fi
                        info "Falling back to an incremental update..."
                        run_extraction "${inc[@]}"
                        return $?
                        ;;
                    partial)
                        if extract_supports --allow-partial; then
                            partial_args=(--allow-partial); partial_used=1
                            attempt=$((attempt - 1))   # don't burn an attempt on the overwrite pass
                            continue
                        fi
                        err "This graphify version has no --allow-partial flag."
                        return "$EX_INCOMPLETE"
                        ;;
                esac
                ;;

            *)
                err "Extraction failed with an unrecognised error (exit $rc). Last output:"
                tail -n 15 "$log" | sed 's/^/    /' >&2
                return "$EX_FAIL"
                ;;
        esac
    done

    err "Gave up after $GFY_MAX_ATTEMPTS attempts. Check quota/network; existing graph is unchanged."
    return "$EX_FAIL"
}

# ============================================================================
# Actions
# ============================================================================
do_incremental_update() {
    step "Incremental knowledge-graph update: $PWD"
    local rc=0
    gfy_ensure_graphify || return $?
    build_args "$PROJECT_DIR" inc
    run_extraction "${EXTRACT_ARGS[@]}" || rc=$?
    gfy_show_stats
    return "$rc"
}

do_full_rebuild() {
    warn "⚠️  Full rebuild of $PWD: semantic cache is bypassed and every doc is re-sent to the model."
    info "Your current graph is backed up first and will NOT be overwritten by a smaller one."
    local rc=0
    gfy_ensure_graphify || return $?
    build_args "$PROJECT_DIR" force
    run_extraction "${EXTRACT_ARGS[@]}" || rc=$?
    gfy_show_stats
    return "$rc"
}

do_extract_paths() {
    local paths="$1" p rc=0 any=0
    local -a arr=()
    read -ra arr <<<"$paths"
    for p in ${arr[@]+"${arr[@]}"}; do
        if [[ ! -e "$p" ]]; then warn "Skipping '$p' (does not exist)."; continue; fi
        any=1
        info "Extracting path: $p"
        gfy_ensure_graphify || return $?
        build_args "$p" inc
        run_extraction "${EXTRACT_ARGS[@]}" || { rc=$?; err "Failed on '$p'."; break; }
    done
    (( any )) || { err "No valid paths supplied."; return "$EX_USAGE"; }
    gfy_show_stats
    return "$rc"
}

do_code_only() {
    local rc=0
    gfy_ensure_graphify || return "$EX_DEP"
    if ! extract_supports --code-only; then
        err "This graphify version does not support --code-only. Run: graphify --help"
        return "$EX_USAGE"
    fi
    step "Code-only update (local AST, no LLM / API key): $PWD"
    CODE_ONLY=1
    build_args "$PROJECT_DIR" inc
    run_extraction "${EXTRACT_ARGS[@]}" || rc=$?
    gfy_show_stats
    return "$rc"
}

do_watch_mode() {
    gfy_ensure_graphify || return $?
    gfy_ensure_api_key  || return $?
    gfy_acquire_lock    || return $?
    local fails=0 rc started runtime cls wait log
    local -a wcmd
    # Older graphify: `extract --watch`; v0.9+: separate `graphify watch <path>` command.
    if extract_supports --watch; then
        wcmd=(graphify extract "$PROJECT_DIR" --backend "$BACKEND" --watch)
    else
        wcmd=(graphify watch "$PROJECT_DIR")
    fi
    step "Live watch mode for $PWD (Ctrl+C to stop): ${wcmd[*]}"

    while true; do
        started=$SECONDS
        gfy_mktemp log
        rc=0
        "${wcmd[@]}" 2>&1 | tee "$log" || rc=${PIPESTATUS[0]}
        gfy_append_log "$log" 300
        (( rc == 0 )) && return 0

        runtime=$((SECONDS - started))
        if (( runtime > 120 )); then fails=0; fi   # a long healthy run resets the counter
        fails=$((fails + 1))
        cls=$(classify_failure "$log")
        warn "Watch exited (code $rc, cause: $cls, ran ${runtime}s, failure $fails/$GFY_MAX_WATCH_FAILURES)"

        case "$cls" in
            missing_dep) err "Missing package. Run: $GFY_SELF --install --force"; return "$EX_DEP" ;;
            auth)        err "API key rejected."; return "$EX_USAGE" ;;
        esac
        if (( fails >= GFY_MAX_WATCH_FAILURES )); then
            err "Watch failed $fails times in a row; giving up."
            return "$EX_FAIL"
        fi
        if [[ "$cls" == rate_limit ]]; then
            wait=$(parse_retry_delay "$log"); (( wait == 0 )) && wait=30
            wait=$((wait + 5))
        else
            wait=$((5 * (1 << (fails - 1)))); (( wait > 120 )) && wait=120
        fi
        gfy_countdown "$wait" "Restarting watch"
    done
}

# ============================================================================
# Antigravity + MCP
# ============================================================================
write_mcp_config() {
    local graph_path="$1" tmp
    mkdir -p "$MCP_CONFIG_DIR"
    gfy_mktemp tmp

    local server_json
    server_json=$(printf '{"command":"uv","args":["run","--with","graphifyy","--with","mcp","-m","graphify.serve","%s"]}' "$graph_path")

    if [[ -f "$MCP_CONFIG_FILE" ]]; then
        if ! gfy_json_valid "$MCP_CONFIG_FILE"; then
            err "$MCP_CONFIG_FILE exists but is not valid JSON. Fix or remove it, then retry."
            return "$EX_FAIL"
        fi
        local bak="$MCP_CONFIG_FILE.bak.$(date +%Y%m%d-%H%M%S)"
        cp -p "$MCP_CONFIG_FILE" "$bak" && info "Backed up MCP config -> $bak"
        if command -v jq >/dev/null 2>&1; then
            jq --argjson s "$server_json" '.mcpServers = ((.mcpServers // {}) + {graphify: $s})' \
                "$MCP_CONFIG_FILE" > "$tmp" || { err "jq merge failed."; return "$EX_FAIL"; }
        elif command -v python3 >/dev/null 2>&1; then
            python3 - "$MCP_CONFIG_FILE" "$server_json" > "$tmp" <<'PY' || { err "python merge failed."; return "$EX_FAIL"; }
import json, sys
cfg = json.load(open(sys.argv[1]))
cfg.setdefault("mcpServers", {})["graphify"] = json.loads(sys.argv[2])
print(json.dumps(cfg, indent=2))
PY
        else
            err "Need jq or python3 to merge into an existing MCP config (refusing to overwrite it)."
            return "$EX_DEP"
        fi
    else
        printf '{"mcpServers":{"graphify":%s}}\n' "$server_json" > "$tmp"
    fi

    if ! gfy_json_valid "$tmp"; then
        err "Generated MCP config is invalid; leaving the original untouched."
        return "$EX_FAIL"
    fi
    mv -f "$tmp" "$MCP_CONFIG_FILE"
    info "✅ MCP server 'graphify' -> $graph_path (in $MCP_CONFIG_FILE)"
}

setup_antigravity_and_mcp() {
    step "Antigravity integration & MCP for $PWD"
    gfy_ensure_graphify || return $?

    if ! graphify antigravity install; then
        warn "'graphify antigravity install' failed (non-fatal). See log for details."
    fi

    # .agent -> .agents compatibility link
    if [[ -d .agents ]]; then
        if [[ -L .agent ]]; then
            [[ "$(readlink .agent)" == ".agents" ]] || { rm -f .agent && ln -s .agents .agent; }
        elif [[ -e .agent ]]; then
            local bak=".agent.backup.$(date +%s)"
            mv .agent "$bak" && warn "Existing .agent moved to $bak"
            ln -s .agents .agent
        else
            ln -s .agents .agent
        fi
        info "Symlink: .agent -> .agents"
    fi

    command -v uv >/dev/null 2>&1 || warn "'uv' not found in PATH; the MCP server command uses 'uv run'."
    [[ -f "$GRAPH_FILE" ]] || warn "$GRAPH_FILE does not exist yet; MCP will work after the first build."
    write_mcp_config "$PWD/$GRAPH_FILE"
}

mcp_configured() {
    [[ -f "$MCP_CONFIG_FILE" ]] && grep -q '"graphify"' "$MCP_CONFIG_FILE" 2>/dev/null
}

# ============================================================================
# Doctor
# ============================================================================
do_doctor() {
    local ok=0 bad=0 v help=""
    chk() { # label, status(0/1), detail
        if [[ "$2" == 0 ]]; then printf '  %s✔%s %-22s %s\n' "$GREEN" "$NC" "$1" "$3"; ok=$((ok+1))
        else printf '  %s✘%s %-22s %s\n' "$RED" "$NC" "$1" "$3"; bad=$((bad+1)); fi
    }
    echo -e "${BOLD}Graphify environment check: $PWD${NC}"
    if command -v graphify >/dev/null 2>&1; then chk graphify 0 "$(command -v graphify)"; else chk graphify 1 "not in PATH (run --install)"; fi
    if command -v python3 >/dev/null 2>&1; then chk python3 0 "$(python3 --version 2>&1)"; else chk python3 1 "missing"; fi
    if command -v jq >/dev/null 2>&1; then chk jq 0 "$(jq --version 2>&1)"; else chk jq 1 "missing (stats/MCP merge degrade)"; fi
    if command -v uv >/dev/null 2>&1; then chk uv 0 "$(uv --version 2>&1)"; else chk uv 1 "missing (needed by MCP server command)"; fi
    if [[ -n "${GEMINI_API_KEY:-}${GOOGLE_API_KEY:-}" ]]; then chk "API key (env)" 0 "set"
    elif _gfy_read_env_key .env >/dev/null || _gfy_read_env_key "$HOME/.env" >/dev/null; then chk "API key (.env)" 0 "found"
    else chk "API key" 1 "not found"; fi
    if [[ -f "$GRAPH_FILE" ]]; then
        if gfy_json_valid "$GRAPH_FILE"; then chk graph.json 0 "valid, $(gfy_graph_metric nodes) nodes"; else chk graph.json 1 "CORRUPT"; fi
    else chk graph.json 1 "not built yet"; fi
    if command -v graphify >/dev/null 2>&1; then
        # required by this script
        for v in --backend --force; do
            if extract_supports "$v"; then chk "extract $v" 0 "supported"; else chk "extract $v" 1 "not listed in graphify --help"; fi
        done
        # optional: used only when present
        for v in --token-budget --code-only --allow-partial; do
            if extract_supports "$v"; then help="supported"; else help="not available (optional)"; fi
            printf '  %s•%s %-22s %s\n' "$BLUE" "$NC" "extract $v" "$help"
        done
    fi
    if mcp_configured; then chk "MCP config" 0 "$MCP_CONFIG_FILE"; else chk "MCP config" 1 "graphify entry missing"; fi
    echo ""
    echo "  Logs:    ${GFY_LOG_DIR:-n/a}"
    echo "  Backups: ${GFY_BACKUP_DIR:-n/a}"
    echo "  Run log: ${GFY_RUN_LOG:-n/a}"
    echo "  Result:  $ok ok, $bad issue(s)"
    (( bad == 0 )) || return 1
}

# ============================================================================
# CLI + menu
# ============================================================================
usage() {
    awk 'NR > 2 && /^#/ { sub(/^# ?/, ""); print; next } NR > 2 { exit }' "$GFY_SELF"
}

interactive_menu() {
    [[ -t 0 ]] || die "$EX_USAGE" "No TTY: pass an action flag (see --help)."
    [[ -t 1 ]] && clear || true
    echo -e "${BOLD}${BLUE}=================================================${NC}"
    echo -e "  ${BOLD}🕸️  Graphify Knowledge Graph Orchestrator${NC}"
    echo -e "  Repo: ${BOLD}$PWD${NC}"
    echo -e "${BOLD}${BLUE}=================================================${NC}"
    if [[ -f "$GRAPH_FILE" ]]; then gfy_show_stats; else info "No knowledge graph found yet in $GRAPHIFY_OUT/"; fi

    echo -e "${BOLD}Choose an action:${NC}"
    echo -e "  1) ${GREEN}${BOLD}Update graph incrementally${NC} (fast, AST + semantic cache) ⭐ RECOMMENDED"
    echo -e "  2) ${BLUE}Start live watch mode${NC}"
    echo -e "  3) ${YELLOW}Rebuild graph from scratch${NC} (backed up; never replaced by a smaller graph)"
    echo -e "  4) ${CYAN}Extract specific subdirectories / packages${NC}"
    echo -e "  5) ${CYAN}Code-only update${NC} (local AST, no API key / LLM cost)"
    echo -e "  6) Setup / refresh Antigravity integration & MCP"
    echo -e "  7) Query the graph"
    echo -e "  8) Diagnostics (doctor)"
    echo -e "  9) Exit"
    echo ""
    local choice rc=0
    read -r -p "Choose option (1-9): " choice || choice=9
    case "${choice:-1}" in
        1) do_incremental_update || rc=$? ;;
        2) do_watch_mode || rc=$? ;;
        3)
            if gfy_confirm "Rebuild the entire graph from scratch?" n strict; then do_full_rebuild || rc=$?
            else info "Rebuild cancelled."; fi ;;
        4)
            local paths=""
            read -r -p "Paths (space-separated, e.g. 'services/api shared/db'): " paths || true
            [[ -n "$paths" ]] && { do_extract_paths "$paths" || rc=$?; } ;;
        5) do_code_only || rc=$? ;;
        6) setup_antigravity_and_mcp || rc=$? ;;
        7)
            local q=""
            read -r -p "Enter query: " q || true
            [[ -n "$q" ]] && { graphify query "$q" || rc=$?; } ;;
        8) do_doctor || rc=$? ;;
        9) info "Bye."; return 0 ;;
        *) err "Invalid option '$choice'."; return "$EX_USAGE" ;;
    esac

    if (( rc == 0 )) && [[ "$choice" =~ ^[1-5]$ ]] && ! mcp_configured; then
        if gfy_confirm "Configure Antigravity MCP integration now?" y; then
            setup_antigravity_and_mcp || rc=$?
        fi
    fi
    return "$rc"
}

main() {
    local action="" target_dir="" install_force=""
    GFY_ARGS="$*"
    while (( $# )); do
        case "$1" in
            -h|--help) usage; exit 0 ;;
            -C|--dir)  shift; [[ -n "${1:-}" ]] || die "$EX_USAGE" "--dir needs a directory"; target_dir="$1" ;;
            -y|--yes) GFY_ASSUME_YES=1 ;;
            --allow-partial) ALLOW_PARTIAL=1 ;;
            --code-only) CODE_ONLY=1 ;;
            --budgets)  shift; [[ -n "${1:-}" ]] || die "$EX_USAGE" "--budgets needs a value"; GFY_TOKEN_BUDGETS="$1" ;;
            --backend)  shift; [[ -n "${1:-}" ]] || die "$EX_USAGE" "--backend needs a value"; BACKEND="$1" ;;
            -u|--update|update)   action=update ;;
            -w|--watch|watch)     action=watch ;;
            -r|--rebuild|rebuild) action=rebuild ;;
            -s|--stats|stats)     action=stats ;;
            --mcp|--setup-mcp)    action=mcp ;;
            --doctor)             action=doctor ;;
            --install)            action=install ;;
            -f|--force)           install_force=force ;;
            *) err "Unknown option: $1"; usage >&2; exit "$EX_USAGE" ;;
        esac
        shift
    done

    if [[ -n "$target_dir" ]]; then
        [[ -d "$target_dir" ]] || die "$EX_USAGE" "Not a directory: $target_dir"
        cd "$target_dir"
    fi

    gfy_init graphify-setup
    local rc=0
    case "$action" in
        update)  do_incremental_update || rc=$? ;;
        watch)   do_watch_mode || rc=$? ;;
        rebuild) do_full_rebuild || rc=$? ;;
        stats)   gfy_show_stats || rc=$? ;;
        mcp)     setup_antigravity_and_mcp || rc=$? ;;
        doctor)  do_doctor || rc=$? ;;
        install) gfy_install_graphify "$install_force" || rc=$? ;;
        "")      gfy_ensure_graphify || exit $?; interactive_menu || rc=$? ;;
    esac
    exit "$rc"
}

main "$@"
