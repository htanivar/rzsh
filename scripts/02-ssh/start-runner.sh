#!/bin/bash
# =============================================================================
# Start local Gitea Actions runner (host mode, no Docker)
# Usage: ./start-runner.sh
# Place this next to the act_runner binary and the .runner file.
# =============================================================================
set -euo pipefail

SSH_HOST="${SSH_HOST:-autopilot}"   # your ssh alias for the VPS
LOCAL_PORT="${LOCAL_PORT:-3000}"    # local end of the tunnel
REMOTE_PORT="${REMOTE_PORT:-3000}"  # Gitea port on the VPS (127.0.0.1)

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[ -x ./act_runner ] || { echo "❌ ./act_runner not found or not executable"; exit 1; }
[ -f .runner ]      || { echo "❌ .runner not found. Register the runner first."; exit 1; }

TUNNEL_PID=""
cleanup() {
    if [ -n "$TUNNEL_PID" ] && kill -0 "$TUNNEL_PID" 2>/dev/null; then
        echo "Closing SSH tunnel..."
        kill "$TUNNEL_PID" 2>/dev/null || true
    fi
}
trap cleanup EXIT INT TERM

port_open() { (echo > "/dev/tcp/127.0.0.1/$LOCAL_PORT") >/dev/null 2>&1; }

# 1. Open the tunnel (skip if something already listens on the port)
if port_open; then
    echo "ℹ️  Port $LOCAL_PORT already open, assuming the tunnel is running."
else
    echo "🔌 Opening SSH tunnel to $SSH_HOST..."
    ssh -N \
        -o ExitOnForwardFailure=yes \
        -o ServerAliveInterval=30 \
        -o ServerAliveCountMax=3 \
        -L "${LOCAL_PORT}:127.0.0.1:${REMOTE_PORT}" "$SSH_HOST" &
    TUNNEL_PID=$!
fi

# 2. Wait for Gitea to answer through the tunnel
echo "⏳ Waiting for Gitea..."
for i in $(seq 1 20); do
    if curl -fs "http://127.0.0.1:${LOCAL_PORT}/api/healthz" >/dev/null 2>&1; then
        echo "✅ Gitea is reachable."
        break
    fi
    if [ "$i" -eq 20 ]; then
        echo "❌ Gitea not reachable on 127.0.0.1:${LOCAL_PORT}"
        exit 1
    fi
    sleep 1
done

# 3. Start the runner (foreground; Ctrl+C stops it and the tunnel)
echo "🚀 Starting act_runner..."
./act_runner daemon
