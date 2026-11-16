#!/usr/bin/env zsh
# examples/18_script_executory_example.sh
# Breadcrumb: README.md -> GLOSSARY.md -> docs/18-script-executory.md -> examples/18_script_executory_example.sh -> tests/18-script-executory.test.sh
# Demonstrates executing existing scripts in sequence (e.g., login.sh -> verify.sh -> update.sh).
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${0:A:h:h}" >&2
  export RZSH_DIR="${0:A:h:h}"
fi

source "${RZSH_DIR}/config/config.sh"
init_config
init_logging

# Create temporary sample scripts to demonstrate a 3-step pipeline
demo_dir="/tmp/rzsh_executory_demo_$$"
mkdir -p "${demo_dir}"
trap 'rm -rf "${demo_dir}"' EXIT

cat <<'EOF' > "${demo_dir}/login.sh"
#!/usr/bin/env zsh
echo "[login.sh] Authenticating user ($1)..."
export DEMO_SESSION_TOKEN="tok_12345"
EOF

cat <<'EOF' > "${demo_dir}/verify.sh"
#!/usr/bin/env zsh
echo "[verify.sh] Checking session token: ${DEMO_SESSION_TOKEN:-none}"
EOF

cat <<'EOF' > "${demo_dir}/update.sh"
#!/usr/bin/env zsh
echo "[update.sh] Applying configuration update..."
EOF

chmod +x "${demo_dir}/login.sh" "${demo_dir}/verify.sh" "${demo_dir}/update.sh"

# 1. Validate a script before running it
log_section "1. Validate Script"
validate_script_executable "${demo_dir}/login.sh" && log_info "login.sh passed validation."

# 2. Execute a single script with arguments
log_section "2. Execute Single Script"
execute_script "${demo_dir}/login.sh" "alice"

# 3. Dry-run a sequence of scripts
log_section "3. Dry-Run Sequence"
execute_scripts_sequence --dry-run "${demo_dir}/login.sh" "${demo_dir}/verify.sh" "${demo_dir}/update.sh"

# 4. Execute scripts sequentially in current shell so DEMO_SESSION_TOKEN flows from login.sh -> verify.sh
log_section "4. Execute Sequence (--source)"
execute_scripts_sequence --source "${demo_dir}/login.sh" "${demo_dir}/verify.sh" "${demo_dir}/update.sh"

# 5. Execute scripts listed in a manifest file
log_section "5. Execute From Manifest File"
cat <<EOF > "${demo_dir}/pipeline.txt"
# Ordered execution pipeline
${demo_dir}/login.sh
${demo_dir}/verify.sh
${demo_dir}/update.sh
EOF
execute_scripts_from_file "${demo_dir}/pipeline.txt"
