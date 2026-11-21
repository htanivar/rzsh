#!/usr/bin/env bash
# =============================================================================
# gitea-client-manager.sh
# Manage the SSH tunnel to your Gitea VPS and the local act_runner (host mode).
#
# Usage: gitea-client-manager.sh <command> [target] [options]
#   start|stop|restart [all|tunnel|runner]
#   status
#   logs [tunnel|runner|all] [-f] [-n LINES]
#   debug
#   register <TOKEN> [NAME] [LABELS]
#   help
#
# Optional config file (shell syntax): ~/.config/gitea-client-manager.conf
#   SSH_HOST=autopilot  LOCAL_PORT=3000  REMOTE_HOST=127.0.0.1  REMOTE_PORT=3000
#   RUNNER_BIN=$HOME/bin/act_runner  RUNNER_DIR=$HOME/bin  RUNNER_CONFIG=
# =============================================================================
set -uo pipefail

CONFIG_FILE="${GCM_CONFIG:-$HOME/.config/gitea-client-manager.conf}"
# shellcheck disable=SC1090
[ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"

SSH_HOST="${SSH_HOST:-autopilot}"            # ssh alias (or user@host)
LOCAL_PORT="${LOCAL_PORT:-3000}"             # local end of the tunnel
REMOTE_HOST="${REMOTE_HOST:-127.0.0.1}"      # target host as seen from the VPS
REMOTE_PORT="${REMOTE_PORT:-3000}"           # Gitea HTTP port on the VPS
RUNNER_BIN="${RUNNER_BIN:-$HOME/bin/act_runner}"
RUNNER_DIR="${RUNNER_DIR:-$(dirname "$RUNNER_BIN")}"   # folder holding .runner
RUNNER_CONFIG="${RUNNER_CONFIG:-}"           # optional config.yaml path
STATE_DIR="${STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/gitea-client}"
HEALTH_WAIT="${HEALTH_WAIT:-20}"             # seconds to wait for Gitea

TUNNEL_LOG="$STATE_DIR/tunnel.log"
RUNNER_LOG="$STATE_DIR/runner.log"
mkdir -p "$STATE_DIR"

# ---------- output helpers ---------------------------------------------------
if [ -t 1 ]; then
    R=$'\e[31m'; G=$'\e[32m'; Y=$'\e[33m'; B=$'\e[1m'; N=$'\e[0m'
else
    R=""; G=""; Y=""; B=""; N=""
fi
info() { printf '%s\n' "$*"; }
ok()   { printf '%s✅ %s%s\n' "$G" "$*" "$N"; }
warn() { printf '%s⚠️  %s%s\n' "$Y" "$*" "$N"; }
err()  { printf '%s❌ %s%s\n' "$R" "$*" "$N" >&2; }
hdr()  { printf '\n%s== %s ==%s\n' "$B" "$*" "$N"; }

# ---------- process helpers --------------------------------------------------
pidfile() { echo "$STATE_DIR/$1.pid"; }

# is_running <name> <pattern-in-cmdline>  (guards against recycled PIDs)
is_running() {
    local pid
    pid=$(cat "$(pidfile "$1")" 2>/dev/null) || return 1
    [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null || return 1
    ps -p "$pid" -o args= 2>/dev/null | grep -q -- "$2"
}
tunnel_running() { is_running tunnel "ssh.*-L ${LOCAL_PORT}:"; }
runner_running() { is_running runner "act_runner"; }

stop_proc() {  # stop_proc <name> <label>
    local name=$1 label=$2 pid i
    pid=$(cat "$(pidfile "$name")" 2>/dev/null || true)
    if [ -z "$pid" ] || ! kill -0 "$pid" 2>/dev/null; then
        info "$label is not running."
        rm -f "$(pidfile "$name")"
        return 0
    fi
    kill "$pid" 2>/dev/null
    for i in $(seq 1 20); do
        kill -0 "$pid" 2>/dev/null || break
        sleep 0.5
    done
    if kill -0 "$pid" 2>/dev/null; then
        warn "$label did not exit, sending SIGKILL."
        kill -9 "$pid" 2>/dev/null
    fi
    rm -f "$(pidfile "$name")"
    ok "$label stopped."
}

rotate_log() {  # truncate logs bigger than 5 MB
    local f=$1
    [ -f "$f" ] && [ "$(wc -c <"$f")" -gt 5242880 ] && tail -n 1000 "$f" >"$f.tmp" && mv "$f.tmp" "$f"
    return 0
}

port_open()     { (echo >"/dev/tcp/127.0.0.1/$LOCAL_PORT") >/dev/null 2>&1; }
gitea_healthy() { curl -fsS -m 3 "http://127.0.0.1:${LOCAL_PORT}/api/healthz" >/dev/null 2>&1; }

wait_for_gitea() {
    local i
    info "⏳ Waiting for Gitea on 127.0.0.1:${LOCAL_PORT}..."
    for i in $(seq 1 "$HEALTH_WAIT"); do
        gitea_healthy && { ok "Gitea is reachable."; return 0; }
        sleep 1
    done
    err "Gitea not reachable through the tunnel (see: $0 debug)."
    return 1
}

# ---------- tunnel -----------------------------------------------------------
start_tunnel() {
    hdr "SSH tunnel"
    if tunnel_running; then
        info "Tunnel already running (PID $(cat "$(pidfile tunnel)"))."
        wait_for_gitea
        return $?
    fi
    if port_open; then
        warn "Port $LOCAL_PORT is already in use by another process (a manual tunnel?). Not starting a new one."
        wait_for_gitea
        return $?
    fi
    rotate_log "$TUNNEL_LOG"
    info "🔌 Opening tunnel: localhost:${LOCAL_PORT} -> ${SSH_HOST}:${REMOTE_HOST}:${REMOTE_PORT}"
    printf '\n--- %s starting tunnel ---\n' "$(date '+%F %T')" >>"$TUNNEL_LOG"
    # BatchMode: fail instead of hanging on a password prompt when in background
    nohup ssh -N \
        -o BatchMode=yes \
        -o ExitOnForwardFailure=yes \
        -o ServerAliveInterval=30 \
        -o ServerAliveCountMax=3 \
        -L "${LOCAL_PORT}:${REMOTE_HOST}:${REMOTE_PORT}" "$SSH_HOST" \
        >>"$TUNNEL_LOG" 2>&1 &
    echo $! >"$(pidfile tunnel)"
    sleep 1.5
    if ! tunnel_running; then
        err "Tunnel failed to start. Last log lines:"
        tail -n 10 "$TUNNEL_LOG" >&2
        rm -f "$(pidfile tunnel)"
        return 1
    fi
    ok "Tunnel started (PID $(cat "$(pidfile tunnel)"))."
    wait_for_gitea
}

stop_tunnel() { hdr "SSH tunnel"; stop_proc tunnel "Tunnel"; }

# ---------- runner -----------------------------------------------------------
runner_precheck() {
    [ -x "$RUNNER_BIN" ] || { err "act_runner not found or not executable: $RUNNER_BIN"; return 1; }
    [ -f "$RUNNER_DIR/.runner" ] || {
        err "No .runner file in $RUNNER_DIR. Register first: $0 register <TOKEN>"
        return 1
    }
}

start_runner() {
    hdr "act_runner"
    if runner_running; then
        info "Runner already running (PID $(cat "$(pidfile runner)"))."
        return 0
    fi
    runner_precheck || return 1
    if ! gitea_healthy; then
        warn "Gitea is not reachable on 127.0.0.1:${LOCAL_PORT}; the runner will keep retrying."
    fi
    rotate_log "$RUNNER_LOG"
    local cfg=()
    [ -n "$RUNNER_CONFIG" ] && cfg=(-c "$RUNNER_CONFIG")
    printf '\n--- %s starting runner ---\n' "$(date '+%F %T')" >>"$RUNNER_LOG"
    (
        cd "$RUNNER_DIR" || exit 1
        nohup "$RUNNER_BIN" daemon "${cfg[@]}" >>"$RUNNER_LOG" 2>&1 &
        echo $! >"$(pidfile runner)"
    )
    sleep 2
    if ! runner_running; then
        err "Runner exited right after start. Last log lines:"
        tail -n 15 "$RUNNER_LOG" >&2
        rm -f "$(pidfile runner)"
        return 1
    fi
    ok "Runner started (PID $(cat "$(pidfile runner)")). Check it shows Idle in Site Administration -> Actions -> Runners."
}

stop_runner() { hdr "act_runner"; stop_proc runner "Runner"; }

register_runner() {
    local token="${1:-}" name="${2:-local-runner}" labels="${3:-ubuntu-latest:host,self-hosted:host}"
    [ -n "$token" ] || { err "Usage: $0 register <TOKEN> [NAME] [LABELS]"; return 1; }
    [ -x "$RUNNER_BIN" ] || { err "act_runner not found: $RUNNER_BIN"; return 1; }
    runner_running && { err "Stop the runner first: $0 stop runner"; return 1; }
    start_tunnel || return 1
    if [ -f "$RUNNER_DIR/.runner" ]; then
        local bak="$RUNNER_DIR/.runner.bak.$(date +%s)"
        cp "$RUNNER_DIR/.runner" "$bak" && rm -f "$RUNNER_DIR/.runner"
        info "Existing .runner backed up to $bak"
    fi
    local cfg=()
    [ -n "$RUNNER_CONFIG" ] && cfg=(-c "$RUNNER_CONFIG")
    hdr "Registering runner '$name' with labels: $labels"
    ( cd "$RUNNER_DIR" && "$RUNNER_BIN" "${cfg[@]}" register --no-interactive \
        --instance "http://127.0.0.1:${LOCAL_PORT}" \
        --token "$token" --name "$name" --labels "$labels" ) \
        && ok "Registered. Now run: $0 start" \
        || { err "Registration failed."; return 1; }
}

# ---------- status -----------------------------------------------------------
cmd_status() {
    hdr "Status"
    if tunnel_running; then
        ok "Tunnel   running (PID $(cat "$(pidfile tunnel)"))  localhost:${LOCAL_PORT} -> ${SSH_HOST}:${REMOTE_HOST}:${REMOTE_PORT}"
    elif port_open; then
        warn "Tunnel   not managed by this script, but port $LOCAL_PORT is open (manual tunnel?)"
    else
        err "Tunnel   stopped"
    fi

    if gitea_healthy; then ok "Gitea    reachable at http://127.0.0.1:${LOCAL_PORT}"
    else err "Gitea    NOT reachable through the tunnel"; fi

    if runner_running; then
        ok "Runner   running (PID $(cat "$(pidfile runner)"))"
    else
        err "Runner   stopped"
    fi

    if [ -f "$RUNNER_DIR/.runner" ]; then
        info "Registered: yes ($RUNNER_DIR/.runner)"
    else
        warn "Registered: no .runner file in $RUNNER_DIR"
    fi
    info "Logs:      $STATE_DIR  (use: $0 logs)"
}

# ---------- logs -------------------------------------------------------------
cmd_logs() {
    local target="runner" follow=0 lines=50
    while [ $# -gt 0 ]; do
        case "$1" in
            tunnel|runner|all) target=$1 ;;
            -f|--follow) follow=1 ;;
            -n) lines="${2:-50}"; shift ;;
            *) err "Unknown logs option: $1"; return 1 ;;
        esac
        shift
    done
    local files=()
    case "$target" in
        tunnel) files=("$TUNNEL_LOG") ;;
        runner) files=("$RUNNER_LOG") ;;
        all)    files=("$TUNNEL_LOG" "$RUNNER_LOG") ;;
    esac
    touch "${files[@]}"
    if [ "$follow" -eq 1 ]; then
        tail -n "$lines" -F "${files[@]}"
    else
        tail -n "$lines" "${files[@]}"
    fi
}

# ---------- debug ------------------------------------------------------------
cmd_debug() {
    hdr "1. act_runner binary"
    if [ -x "$RUNNER_BIN" ]; then
        ok "$RUNNER_BIN"
        "$RUNNER_BIN" --version 2>&1 | head -n 1
    else
        err "Missing or not executable: $RUNNER_BIN"
    fi

    hdr "2. Registration (.runner)"
    if [ -f "$RUNNER_DIR/.runner" ]; then
        ok "$RUNNER_DIR/.runner exists"
        local labels
        labels=$(tr -d '\n ' <"$RUNNER_DIR/.runner" | grep -o '"labels":\[[^]]*\]' || true)
        info "Labels: ${labels:-<none found>}"
        if echo "$labels" | grep -q 'docker://'; then
            warn "A label uses docker:// but you don't want Docker. Re-register: $0 register <TOKEN>"
        fi
    else
        err "No .runner in $RUNNER_DIR (run: $0 register <TOKEN>)"
    fi
    command -v docker >/dev/null 2>&1 \
        && info "docker: installed (only used if a label contains docker://)" \
        || info "docker: not installed (fine for :host labels)"

    hdr "3. SSH config for '$SSH_HOST'"
    ssh -G "$SSH_HOST" 2>/dev/null | grep -iE '^(hostname|user|port|identityfile|identitiesonly) ' || warn "ssh -G failed"
    local f
    while read -r f; do
        f="${f/#\~/$HOME}"
        [ -f "$f" ] && ok "key present: $f" || warn "key missing: $f"
    done < <(ssh -G "$SSH_HOST" 2>/dev/null | awk 'tolower($1)=="identityfile"{print $2}')

    hdr "4. Non-interactive SSH login test"
    local out
    if out=$(ssh -o BatchMode=yes -o ConnectTimeout=8 "$SSH_HOST" true 2>&1); then
        ok "SSH key login works"
    else
        err "SSH key login failed (the tunnel can't start in background without it):"
        info "$out"
    fi

    hdr "5. Tunnel and Gitea"
    tunnel_running && ok "Tunnel process running" || warn "Tunnel process not running"
    port_open && ok "Port $LOCAL_PORT is listening" || err "Port $LOCAL_PORT is not listening"
    local code
    code=$(curl -s -o /dev/null -m 4 -w '%{http_code}' "http://127.0.0.1:${LOCAL_PORT}/api/healthz" 2>/dev/null || true)
    info "GET /api/healthz -> HTTP ${code:-no response}"

    hdr "6. Runner process"
    runner_running && ok "Runner running (PID $(cat "$(pidfile runner)"))" || err "Runner not running"

    hdr "7. Recent logs"
    info "--- tunnel.log (last 10) ---"; tail -n 10 "$TUNNEL_LOG" 2>/dev/null || info "(empty)"
    info "--- runner.log (last 15) ---"; tail -n 15 "$RUNNER_LOG" 2>/dev/null || info "(empty)"
}

# ---------- dispatch ---------------------------------------------------------
usage() {
    cat <<EOF
Usage: ${0##*/} <command> [target] [options]

Commands:
  start   [all|tunnel|runner]   Start (default: all; tunnel first, runner after Gitea answers)
  stop    [all|tunnel|runner]   Stop (default: all; runner first, then tunnel)
  restart [all|tunnel|runner]   Stop then start
  status                        Show tunnel, Gitea and runner state
  logs    [tunnel|runner|all] [-f] [-n LINES]
                                Show logs (default: runner, last 50 lines)
  debug                         Run diagnostics (binary, labels, SSH, port, health, logs)
  register <TOKEN> [NAME] [LABELS]
                                Register the runner (host labels by default)
  help                          Show this help

Current settings:
  SSH_HOST=$SSH_HOST  LOCAL_PORT=$LOCAL_PORT  REMOTE=$REMOTE_HOST:$REMOTE_PORT
  RUNNER_BIN=$RUNNER_BIN  RUNNER_DIR=$RUNNER_DIR
  STATE_DIR=$STATE_DIR
Override via env vars or $CONFIG_FILE
EOF
}

do_start() {
    case "${1:-all}" in
        tunnel) start_tunnel ;;
        runner) start_runner ;;
        all)    start_tunnel && start_runner ;;
        *) err "Unknown target: $1"; return 1 ;;
    esac
}
do_stop() {
    case "${1:-all}" in
        tunnel) stop_tunnel ;;
        runner) stop_runner ;;
        all)    stop_runner; stop_tunnel ;;
        *) err "Unknown target: $1"; return 1 ;;
    esac
}

cmd="${1:-help}"; shift || true
case "$cmd" in
    start)    do_start "${1:-all}" ;;
    stop)     do_stop "${1:-all}" ;;
    restart)  do_stop "${1:-all}"; do_start "${1:-all}" ;;
    status)   cmd_status ;;
    logs)     cmd_logs "$@" ;;
    debug)    cmd_debug ;;
    register) register_runner "$@" ;;
    help|-h|--help) usage ;;
    *) err "Unknown command: $cmd"; usage; exit 1 ;;
esac
