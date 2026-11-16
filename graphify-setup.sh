#!/usr/bin/env bash
#
# graphify-setup.sh - entry point for graphify setup (sources the library)
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=graphify-common.sh
source "$SCRIPT_DIR/graphify-common.sh"

gfy_init "graphify-setup"

# ensure dependencies + API key, then run whatever setup you intended
gfy_ensure_graphify || die "$?" "graphify is not installed"
gfy_ensure_api_key || die "$?" "Gemini API key missing"

info "Graphify setup complete."
