#!/usr/bin/env zsh
# examples/99_evidences_example.sh
# Non-technical guide to generating incident audit snapshots and markdown reports.

source "$(dirname "$0")/../config/config.sh"
init_config

# 1. Start evidence session
init_evidence
echo "Started evidence snapshot session inside directory: ${CURRENT_EVIDENCE_DIR}"

# 2. Collect core operating system and network information
collect_environment_evidence
collect_network_evidence
collect_git_evidence

# 3. Add file snapshots
local file_to_log="${PROJECT_ROOT}/logs/notes.txt"
echo "Dummy context info" > "${file_to_log}"
collect_file_evidence "${file_to_log}"

# 4. Generate visual report summary
echo "Synthesizing evidence files..."
evidence_to_markdown

# 5. Archive session files to compressed tarball
local archive=$(evidence_archive)
echo "Archived incident bundle package: ${archive}"
