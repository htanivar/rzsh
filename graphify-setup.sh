#!/usr/bin/env bash
#
# graphify-setup.sh - Universal Graphify Setup, Incremental Updater & Rate Limit Manager
# Builds, updates, and configures knowledge graphs with automatic Gemini 429 rate limit recovery.
#
# Usage:
#   ./graphify-setup.sh                # Interactive menu
#   ./graphify-setup.sh --update (-u)  # Fast incremental update
#   ./graphify-setup.sh --watch (-w)   # Live file watcher mode
#   ./graphify-setup.sh --rebuild (-r) # Full clean rebuild
#   ./graphify-setup.sh --stats (-s)   # Graph statistics
#   ./graphify-setup.sh --mcp          # Configure MCP & Antigravity
#

set -eo pipefail

# Ensure user-installed binaries are in PATH
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.pyenv/shims:$PATH"

# Configuration
PROJECT_DIR="."
GRAPHIFY_OUTPUT="graphify-out"
GRAPH_FILE="$GRAPHIFY_OUTPUT/graph.json"
MCP_CONFIG_DIR="$HOME/.gemini/antigravity"
MCP_CONFIG_FILE="$MCP_CONFIG_DIR/mcp_config.json"

# ANSI Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

print_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# -----------------------------------------------------------------------------
# 1. Dependency & Environment Checks
# -----------------------------------------------------------------------------
get_installer_script() {
    local candidate="scripts/lib/graphify/install-graphify.sh"
    if [ -f "$candidate" ]; then
        echo "$candidate"
        return 0
    fi
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [ -f "$script_dir/install-graphify.sh" ]; then
        echo "$script_dir/install-graphify.sh"
        return 0
    fi
    if [ -f "$script_dir/scripts/lib/graphify/install-graphify.sh" ]; then
        echo "$script_dir/scripts/lib/graphify/install-graphify.sh"
        return 0
    fi
    echo "$candidate"
}

ensure_graphify() {
    export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.pyenv/shims:$PATH"

    if ! command -v graphify &> /dev/null; then
        local installer
        installer=$(get_installer_script)

        print_warning "'graphify' binary not found in PATH."
        if [ -f "$installer" ]; then
            print_step "Launching installer: $installer..."
            chmod +x "$installer" 2>/dev/null || true
            if ! "$installer"; then
                print_error "Graphify installation failed or was cancelled."
                exit 1
            fi
            # Re-export PATH after installation
            export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.pyenv/shims:$PATH"
        else
            print_error "Installer script not found at $installer."
            print_info "Please install graphify manually using: uv tool install graphify (or pip install graphify)"
            exit 1
        fi

        if ! command -v graphify &> /dev/null; then
            print_error "Failed to locate 'graphify' after installation. Please verify that your installation directory is in your PATH."
            exit 1
        fi
    fi
}

# -----------------------------------------------------------------------------
# 2. Dynamic 429 Quota & Rate Limit Parser
# -----------------------------------------------------------------------------
ensure_api_key() {
    # 1. Already set in environment
    if [ -n "${GEMINI_API_KEY:-}" ] || [ -n "${GOOGLE_API_KEY:-}" ]; then
        return 0
    fi

    # 2. Check local .env or ~/.env
    local env_candidates=(".env" "$HOME/.env")
    for env_file in "${env_candidates[@]}"; do
        if [ -f "$env_file" ]; then
            local loaded_key
            loaded_key=$(grep -E '^(GEMINI_API_KEY|GOOGLE_API_KEY)=' "$env_file" 2>/dev/null | head -n 1 | cut -d '=' -f2- | sed -e 's/^[ " '\''\t]*//' -e 's/[ " '\''\t]*$//')
            if [ -n "$loaded_key" ]; then
                export GEMINI_API_KEY="$loaded_key"
                print_info "Loaded Gemini API key from $env_file"
                return 0
            fi
        fi
    done

    # 3. Interactive prompt if terminal is available
    echo ""
    echo -e "${YELLOW}[WARNING]${NC} Neither ${BOLD}GEMINI_API_KEY${NC} nor ${BOLD}GOOGLE_API_KEY${NC} is set in your environment."
    echo -e "         A Gemini API key is required to build/update the knowledge graph with the Gemini backend."
    echo -e "         Get a free API key at: ${CYAN}https://aistudio.google.com/app/apikey${NC}"
    echo ""

    if [ -t 0 ]; then
        read -rsp "Enter your Gemini API Key (input will be hidden): " input_key
        echo ""
        if [ -n "$input_key" ]; then
            export GEMINI_API_KEY="$input_key"
            read -rp "Would you like to save this key to .env for future runs? [y/N]: " save_choice
            if [[ "$save_choice" =~ ^[Yy]$ ]]; then
                echo "GEMINI_API_KEY=\"$input_key\"" >> .env
                chmod 600 .env
                print_info "Saved key to .env"
                if [ -f ".gitignore" ] && ! grep -q "^\.env" .gitignore; then
                    echo ".env" >> .gitignore
                    print_info "Added '.env' to .gitignore"
                fi
            fi
            return 0
        fi
    fi

    print_error "GEMINI_API_KEY or GOOGLE_API_KEY is required to run graph extraction."
    echo -e "   Please export it before running:"
    echo -e "   ${CYAN}export GEMINI_API_KEY=\"your_api_key_here\"${NC}"
    echo -e "   Or add it to ${CYAN}.env${NC} in the project root."
    return 1
}

parse_retry_delay() {
    local log_file="$1"
    if [ ! -f "$log_file" ]; then
        echo 0
        return
    fi
    # Check for retryDelay or wait seconds from Gemini / Google API errors
    local raw_val
    raw_val=$(grep -o -E "(retryDelay.*|Please retry in [0-9.]+|RESOURCE_EXHAUSTED.*[0-9]+s)" "$log_file" 2>/dev/null | head -n 1 | grep -o -E "[0-9.]+" | head -n 1 || echo "")
    if [ -n "$raw_val" ]; then
        # Round up using awk
        local int_sec
        int_sec=$(echo "$raw_val" | awk '{print int($1 == int($1) ? $1 : int($1)+1)}')
        echo "${int_sec:-0}"
    else
        # If generic 429/quota error without explicit delay, return default 30s backoff
        if grep -q -E "429|quota|RESOURCE_EXHAUSTED|rate limit" "$log_file" 2>/dev/null; then
            echo 30
        else
            echo 0
        fi
    fi
}

# -----------------------------------------------------------------------------
# 3. Robust Batch Extraction with Rate-Limit & 429 Backoff
# -----------------------------------------------------------------------------
run_extraction_with_backoff() {
    ensure_api_key || return 1
    local extract_args=("$@")
    local max_retries=5
    local attempt=0
    
    while [ $attempt -lt $max_retries ]; do
        attempt=$((attempt + 1))
        local log_file="/tmp/graphify_run_$$.log"
        
        print_info "Running: graphify extract ${extract_args[*]}"
        
        # Run extraction and pipe to both console and log file
        if graphify extract "${extract_args[@]}" 2>&1 | tee "$log_file"; then
            rm -f "$log_file"
            print_info "✅ Extraction step succeeded."
            return 0
        else
            local retry_sec
            retry_sec=$(parse_retry_delay "$log_file")
            
            # Check for missing package dependencies (openai, tree_sitter_sql, etc.)
            if grep -q -E "the '.*' package is required|requires the .* package|tree_sitter_sql not installed" "$log_file" 2>/dev/null; then
                rm -f "$log_file"
                echo ""
                print_warning "⚠️ Missing required backend/parser package (e.g. 'openai' for Gemini backend or 'tree_sitter_sql')."
                print_info "To install the missing packages, run:"
                echo -e "   ${CYAN}./graphify-setup.sh --install --force${NC}"
                echo -e "   or: ${CYAN}uv tool install \"graphifyy[gemini,sql]\" --force${NC}"
                echo -e "   or: ${CYAN}pip install openai tree_sitter_sql${NC}"
                echo ""
                if [ -t 0 ]; then
                    read -rp "Would you like to install the required dependencies now? [Y/n]: " auto_install_choice
                    if [[ ! "$auto_install_choice" =~ ^[Nn]$ ]]; then
                        local installer
                        installer=$(get_installer_script)
                        if [ -f "$installer" ]; then
                            "$installer" --force
                            print_info "🔄 Retrying extraction..."
                            continue
                        fi
                    fi
                fi
                return 1
            fi
            rm -f "$log_file"

            if [ "$retry_sec" -gt 0 ]; then
                local wait_time=$((retry_sec + 5))
                print_warning "⚠️ Gemini API rate limit / 429 quota reached (suggested wait: ${retry_sec}s)."
                print_warning "⏳ Pausing for ${wait_time}s (delay + 5s buffer) before retry $attempt/$max_retries..."
                for ((w=wait_time; w>0; w--)); do
                    echo -ne "\r${YELLOW}⏳ Resuming in $w seconds...${NC}    "
                    sleep 1
                done
                echo ""
                print_info "🔄 Resuming incremental extraction..."
            else
                print_error "❌ Graphify extraction encountered an unrecoverable error."
                return 1
            fi
        fi
    done
    
    print_error "❌ Max retries ($max_retries) reached. Please check your Gemini API quota or network connection."
    return 1
}

# -----------------------------------------------------------------------------
# 4. Graph Statistics & Reporting
# -----------------------------------------------------------------------------
show_graph_stats() {
    if [ ! -f "$GRAPH_FILE" ]; then
        print_warning "No graph found at $GRAPH_FILE. Run setup or update first."
        return
    fi
    
    local graph_size
    if command -v numfmt &> /dev/null; then
        graph_size=$(wc -c < "$GRAPH_FILE" | numfmt --to=si)
    else
        graph_size=$(wc -c < "$GRAPH_FILE")
    fi
    
    local nodes
    local edges
    local communities
    nodes=$(jq '.nodes | length' "$GRAPH_FILE" 2>/dev/null || echo "0")
    edges=$(jq '.edges | length' "$GRAPH_FILE" 2>/dev/null || echo "0")
    communities=$(jq '.communities | length' "$GRAPH_FILE" 2>/dev/null || echo "N/A")
    
    echo ""
    echo -e "${BOLD}${BLUE}📊 Current Knowledge Graph Stats${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "📁 Graph File:    ${BOLD}$GRAPH_FILE${NC} ($graph_size)"
    echo -e "🟢 Total Nodes:   ${BOLD}$nodes${NC}"
    echo -e "🔗 Total Edges:   ${BOLD}$edges${NC}"
    echo -e "🌐 Communities:   ${BOLD}$communities${NC}"
    echo -e "💡 Token Savings: ~95-99% per query vs full context grep"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# -----------------------------------------------------------------------------
# 5. Antigravity & MCP Setup
# -----------------------------------------------------------------------------
setup_antigravity_and_mcp() {
    print_step "Setting up Antigravity integration & MCP configuration..."
    
    # 1. Antigravity integration
    graphify antigravity install || true
    
    # 2. Symlink .agent -> .agents for compatibility
    if [ -d ".agents" ]; then
        if [ -L ".agent" ]; then
            rm .agent
        elif [ -d ".agent" ]; then
            mv .agent .agent.backup
        fi
        ln -s .agents .agent
        print_info "✅ Symlink created: .agent -> .agents"
    fi
    
    # 3. MCP configuration
    mkdir -p "$MCP_CONFIG_DIR"
    local workspace_path
    workspace_path="$(pwd)"
    
    if command -v jq &> /dev/null; then
        if [ -f "$MCP_CONFIG_FILE" ]; then
            local tmp_mcp
            tmp_mcp=$(mktemp)
            jq --arg graph_path "$workspace_path/graphify-out/graph.json" \
               '.mcpServers.graphify = {"command": "uv", "args": ["run", "--with", "graphifyy", "--with", "mcp", "-m", "graphify.serve", $graph_path]}' \
               "$MCP_CONFIG_FILE" > "$tmp_mcp" 2>/dev/null && mv "$tmp_mcp" "$MCP_CONFIG_FILE"
        else
            cat > "$MCP_CONFIG_FILE" << EOF
{
  "mcpServers": {
    "graphify": {
      "command": "uv",
      "args": ["run", "--with", "graphifyy", "--with", "mcp", "-m", "graphify.serve", "$workspace_path/graphify-out/graph.json"]
    }
  }
}
EOF
        fi
        print_info "✅ MCP server configured in $MCP_CONFIG_FILE"
    else
        cat > "$MCP_CONFIG_FILE" << EOF
{
  "mcpServers": {
    "graphify": {
      "command": "uv",
      "args": ["run", "--with", "graphifyy", "--with", "mcp", "-m", "graphify.serve", "$workspace_path/graphify-out/graph.json"]
    }
  }
}
EOF
        print_info "✅ MCP config written to $MCP_CONFIG_FILE"
    fi
}

# -----------------------------------------------------------------------------
# 6. Incremental Update Execution
# -----------------------------------------------------------------------------
do_incremental_update() {
    print_step "Running incremental knowledge graph update..."
    local old_nodes=0
    local old_edges=0
    if [ -f "$GRAPH_FILE" ]; then
        old_nodes=$(jq '.nodes | length' "$GRAPH_FILE" 2>/dev/null || echo "0")
        old_edges=$(jq '.edges | length' "$GRAPH_FILE" 2>/dev/null || echo "0")
    fi
    
    run_extraction_with_backoff "$PROJECT_DIR" --backend gemini --incremental
    
    show_graph_stats
}

# -----------------------------------------------------------------------------
# 7. Live Watch Mode
# -----------------------------------------------------------------------------
do_watch_mode() {
    ensure_api_key || return 1
    print_step "Starting Graphify live watch mode..."
    print_info "Files will be automatically analyzed on save (AST-cached)."
    print_info "Press Ctrl+C to stop watch mode."
    
    while true; do
        local log_file="/tmp/graphify_watch_$$.log"
        if graphify extract "$PROJECT_DIR" --backend gemini --watch 2>&1 | tee "$log_file"; then
            break
        else
            local retry_sec
            retry_sec=$(parse_retry_delay "$log_file")
            rm -f "$log_file"
            if [ "$retry_sec" -gt 0 ]; then
                local wait_time=$((retry_sec + 5))
                print_warning "⚠️ Watch mode paused due to rate limit (delay: ${retry_sec}s)."
                for ((w=wait_time; w>0; w--)); do
                    echo -ne "\r${YELLOW}⏳ Resuming watch in $w seconds...${NC}    "
                    sleep 1
                done
                echo ""
            else
                print_warning "Watch mode interrupted. Restarting in 5s..."
                sleep 5
            fi
        fi
    done
}

# -----------------------------------------------------------------------------
# 8. Full Rebuild
# -----------------------------------------------------------------------------
do_full_rebuild() {
    print_warning "⚠️ Performing a full graph rebuild from scratch..."
    run_extraction_with_backoff "$PROJECT_DIR" --backend gemini --force
    show_graph_stats
}

# -----------------------------------------------------------------------------
# 9. CLI Argument Handling & Interactive Menu
# -----------------------------------------------------------------------------
main() {
    # Check for help flag early to avoid prompting for installations
    case "${1:-}" in
        --help|-h)
            echo "Usage: ./graphify-setup.sh [OPTION]"
            echo ""
            echo "Options:"
            echo "  -u, --update    Incrementally update graph with rate-limit recovery"
            echo "  -w, --watch     Start continuous live watch mode"
            echo "  -r, --rebuild   Force full clean rebuild of the graph"
            echo "  -s, --stats     Display current graph statistics"
            echo "  --mcp           Configure Antigravity & MCP server"
            echo "  --install       Run dependency checker & installer (install-graphify.sh)"
            echo "  -h, --help      Display this help message"
            exit 0
            ;;
        --install)
            local installer
            installer=$(get_installer_script)
            if [ -f "$installer" ]; then
                shift
                exec "$installer" "$@"
            else
                print_error "Installer script not found at $installer."
                exit 1
            fi
            ;;
    esac

    ensure_graphify

    # CLI Argument Flags
    case "${1:-}" in
        --update|-u|update)
            do_incremental_update
            exit 0
            ;;
        --watch|-w|watch)
            do_watch_mode
            exit 0
            ;;
        --rebuild|-r|rebuild)
            do_full_rebuild
            exit 0
            ;;
        --stats|-s|stats)
            show_graph_stats
            exit 0
            ;;
        --mcp|--setup-mcp)
            setup_antigravity_and_mcp
            exit 0
            ;;
    esac
    
    # Interactive Menu
    clear
    echo -e "${BOLD}${BLUE}=================================================${NC}"
    echo -e "  ${BOLD}🕸️ Graphify Knowledge Graph Orchestrator${NC}"
    echo -e "${BOLD}${BLUE}=================================================${NC}"
    
    if [ -f "$GRAPH_FILE" ]; then
        show_graph_stats
    else
        print_info "No knowledge graph found yet in $GRAPHIFY_OUTPUT/"
    fi
    
    echo -e "${BOLD}Choose an action:${NC}"
    echo -e "  1) ${GREEN}${BOLD}Update graph incrementally${NC} (Fast, AST + semantic cache) ⭐ RECOMMENDED"
    echo -e "  2) ${BLUE}Start live watch mode${NC} (Auto-syncs changes on save)"
    echo -e "  3) ${YELLOW}Rebuild graph from scratch${NC} (Full force rebuild with 429 recovery)"
    echo -e "  4) ${CYAN}Extract specific subdirectories / packages${NC}"
    echo -e "  5) ${CYAN}Extract specific file types (Go, TypeScript, Python, etc.)${NC}"
    echo -e "  6) Setup / Refresh Antigravity integration & MCP"
    echo -e "  7) Query the graph"
    echo -e "  8) Exit"
    echo ""
    read -rp "Choose option (1-8): " choice
    
    case "$choice" in
        1|"")
            do_incremental_update
            ;;
        2)
            do_watch_mode
            ;;
        3)
            echo ""
            read -rp "Are you sure you want to rebuild the entire graph from scratch? [y/N]: " confirm_rebuild
            if [[ "$confirm_rebuild" =~ ^[Yy]$ ]]; then
                do_full_rebuild
            else
                print_info "Rebuild cancelled."
            fi
            ;;
        4)
            echo ""
            echo "Enter directory paths to extract (e.g., 'services/rtwin shared/twin-db'):"
            read -rp "Paths: " custom_paths
            if [ -n "$custom_paths" ]; then
                IFS=' ' read -ra path_arr <<< "$custom_paths"
                for p in "${path_arr[@]}"; do
                    print_info "Extracting path: $p"
                    run_extraction_with_backoff "$p" --backend gemini --incremental
                done
                show_graph_stats
            fi
            ;;
        5)
            echo ""
            echo "Select file extractors:"
            echo "  1) Go (go)"
            echo "  2) JavaScript / TypeScript (ts,js)"
            echo "  3) Python (python)"
            echo "  4) Documentation & Markdown (doc,text)"
            echo "  5) All code extractors (go,ts,js,python,doc,text)"
            read -rp "Choose (1-5): " ext_choice
            local ext_flag="go,doc,text"
            case "$ext_choice" in
                1) ext_flag="go" ;;
                2) ext_flag="ts,js" ;;
                3) ext_flag="python" ;;
                4) ext_flag="doc,text" ;;
                5) ext_flag="go,ts,js,python,doc,text" ;;
            esac
            run_extraction_with_backoff "$PROJECT_DIR" --backend gemini --incremental --extractors "$ext_flag"
            show_graph_stats
            ;;
        6)
            setup_antigravity_and_mcp
            ;;
        7)
            echo ""
            read -rp "Enter query: " user_query
            if [ -n "$user_query" ]; then
                local query_script="scripts/lib/graphify/query-graphify.sh"
                if [ -f "$query_script" ]; then
                    "$query_script" "$user_query"
                elif [ -f "$(dirname "${BASH_SOURCE[0]}")/query-graphify.sh" ]; then
                    "$(dirname "${BASH_SOURCE[0]}")/query-graphify.sh" "$user_query"
                else
                    graphify query "$user_query"
                fi
            fi
            ;;
        8)
            print_info "Exiting."
            exit 0
            ;;
        *)
            print_error "Invalid option."
            exit 1
            ;;
    esac
    
    # Prompt for MCP setup if not configured
    if [ ! -f "$MCP_CONFIG_FILE" ] || ! grep -q "graphify" "$MCP_CONFIG_FILE" 2>/dev/null; then
        echo ""
        read -rp "Configure Antigravity MCP integration now? [Y/n]: " setup_mcp_choice
        if [[ ! "$setup_mcp_choice" =~ ^[Nn]$ ]]; then
            setup_antigravity_and_mcp
        fi
    fi
}

main "$@"