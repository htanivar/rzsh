# functions/14-evidence.sh

# Protect against double sourcing
if [[ -n "${_EVIDENCE_SH_SOURCED:-}" ]]; then
  return 0
fi
readonly _EVIDENCE_SH_SOURCED=1

# Ensure config is sourced if available
if [[ -f "${PROJECT_ROOT:-.}/config/config.sh" ]]; then
  source "${PROJECT_ROOT:-.}/config/config.sh"
fi

# Global state for current evidence collection directory
CURRENT_EVIDENCE_DIR=""

# /**
#  * @function init_evidence
#  * @description Initializes an evidence collection session, creating a timestamped folder inside EVIDENCE_DIR.
#  * @param None
#  * @return {number} 0 on success, or non-zero on failure.
#  * @example
#  *   init_evidence
#  */
init_evidence() {
  local ev_dir="${EVIDENCE_DIR:-${PROJECT_ROOT:-.}/evidence}"
  local ts
  ts=$(date +%Y%m%d_%H%M%S)
  CURRENT_EVIDENCE_DIR="${ev_dir}/evidence_${ts}"
  
  if ! mkdir -p "${CURRENT_EVIDENCE_DIR}" 2>/dev/null; then
    return 1
  fi
  
  # Initialize metadata file
  local meta
  meta='{"initialized_at":"'"$(date -u +"%Y-%m-%dT%H:%M:%SZ")"'","files":[]}'
  echo "${meta}" > "${CURRENT_EVIDENCE_DIR}/metadata.json"
  
  return 0
}

# Internal helper to add file metadata to session tracking
_add_evidence_file() {
  local filename="$1"
  local type="$2"
  local meta_file="${CURRENT_EVIDENCE_DIR}/metadata.json"
  if [[ -f "${meta_file}" ]]; then
    local content
    content=$(cat "${meta_file}")
    content=$(echo "${content}" | jq --arg name "${filename}" --arg type "${type}" '.files += [{"name": $name, "type": $type, "collected_at": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"}]')
    echo "${content}" > "${meta_file}"
  fi
}

# /**
#  * @function collect_environment_evidence
#  * @description Collects operating system, kernel, arch, env vars, user, and running process info.
#  * @param None
#  * @return {number} 0 on success.
#  * @example
#  *   collect_environment_evidence
#  */
collect_environment_evidence() {
  if [[ -z "${CURRENT_EVIDENCE_DIR}" ]]; then
    return 1
  fi
  
  local env_json
  env_json=$(jq -n \
    --arg os "$(uname -s)" \
    --arg kernel "$(uname -r)" \
    --arg arch "$(uname -m)" \
    --arg user "${USER:-$(whoami)}" \
    --arg env_vars "$(env | head -n 50)" \
    --arg processes "$(ps aux | head -n 30)" \
    '{os: $os, kernel: $kernel, arch: $arch, user: $user, sample_env: ($env_vars | split("\n")), sample_processes: ($processes | split("\n"))}')
  
  echo "${env_json}" > "${CURRENT_EVIDENCE_DIR}/environment.json"
  _add_evidence_file "environment.json" "environment"
  return 0
}

# /**
#  * @function collect_script_evidence
#  * @description Collects metadata of the executing script including name, path, and arguments.
#  * @param {string[]} args - Pass in "$@" (the script arguments).
#  * @return {number} 0 on success.
#  * @example
#  *   collect_script_evidence "$@"
#  */
collect_script_evidence() {
  if [[ -z "${CURRENT_EVIDENCE_DIR}" ]]; then
    return 1
  fi
  
  local -a script_args
  script_args=( "$@" )
  
  local script_json
  script_json=$(jq -n \
    --arg name "${SCRIPT_NAME:-unknown}" \
    --arg path "${0:A}" \
    --argjson args "$(printf '%s\n' "${script_args[@]}" | jq -R . | jq -s .)" \
    '{name: $name, path: $path, args: $args}')
  
  echo "${script_json}" > "${CURRENT_EVIDENCE_DIR}/script.json"
  _add_evidence_file "script.json" "script"
  return 0
}

# /**
#  * @function collect_network_evidence
#  * @description Collects network configuration details, DNS servers, and basic external connectivity status.
#  * @param None
#  * @return {number} 0 on success.
#  * @example
#  *   collect_network_evidence
#  */
collect_network_evidence() {
  if [[ -z "${CURRENT_EVIDENCE_DIR}" ]]; then
    return 1
  fi
  
  local ips
  ips=$(ip addr show 2>/dev/null || ifconfig 2>/dev/null || echo "unknown")
  local dns
  dns=$(cat /etc/resolv.conf 2>/dev/null || echo "unknown")
  local ping_status="offline"
  if ping -c 1 -W 2 8.8.8.8 &>/dev/null; then
    ping_status="online"
  fi
  
  local net_json
  net_json=$(jq -n \
    --arg ips "${ips}" \
    --arg dns "${dns}" \
    --arg connectivity "${ping_status}" \
    '{interfaces: ($ips | split("\n")), dns: ($dns | split("\n")), connectivity: $connectivity}')
  
  echo "${net_json}" > "${CURRENT_EVIDENCE_DIR}/network.json"
  _add_evidence_file "network.json" "network"
  return 0
}

# /**
#  * @function collect_file_evidence
#  * @description Collects size, checksums, metadata, and head contents for specified target files.
#  * @param {string} files - Space-separated list of file paths.
#  * @return {number} 0 on success.
#  * @example
#  *   collect_file_evidence "/etc/hosts /etc/resolv.conf"
#  */
collect_file_evidence() {
  if [[ -z "${CURRENT_EVIDENCE_DIR}" ]]; then
    return 1
  fi
  
  local files_to_collect="$1"
  local -a files_arr
  files_arr=( ${(s: :)${files_to_collect//,/ }} )
  
  local -a collected
  collected=()
  local f
  for f in "${files_arr[@]}"; do
    if [[ -f "${f}" ]]; then
      local size
      size=$(stat -c %s "${f}" 2>/dev/null || stat -f %z "${f}" 2>/dev/null)
      local hash
      hash=$(sha256sum "${f}" 2>/dev/null | cut -d' ' -f1 || echo "unknown")
      local content
      content=$(cat "${f}" | head -n 50)
      
      local file_entry
      file_entry=$(jq -n \
        --arg path "${f:A}" \
        --arg size "${size}" \
        --arg hash "${hash}" \
        --arg content "${content}" \
        '{path: $path, size: $size, hash: $hash, sample_content: $content}')
      collected+=("${file_entry}")
    fi
  done
  
  local json_array
  json_array=$(printf '%s\n' "${collected[@]}" | jq -s .)
  echo "${json_array}" > "${CURRENT_EVIDENCE_DIR}/files.json"
  _add_evidence_file "files.json" "files"
  return 0
}

# /**
#  * @function collect_docker_evidence
#  * @description Collects running Docker containers and cached Docker images lists.
#  * @param None
#  * @return {number} 0 on success.
#  * @example
#  *   collect_docker_evidence
#  */
collect_docker_evidence() {
  if [[ -z "${CURRENT_EVIDENCE_DIR}" ]]; then
    return 1
  fi
  
  local images="Docker not available"
  local containers="Docker not available"
  if command -v docker &>/dev/null; then
    images=$(docker images --format "{{.Repository}}:{{.Tag}}" | head -n 30)
    containers=$(docker ps --format "{{.Names}} ({{.Image}})" | head -n 30)
  fi
  
  local docker_json
  docker_json=$(jq -n \
    --arg img "${images}" \
    --arg cnt "${containers}" \
    '{images: ($img | split("\n")), containers: ($cnt | split("\n"))}')
  
  echo "${docker_json}" > "${CURRENT_EVIDENCE_DIR}/docker.json"
  _add_evidence_file "docker.json" "docker"
  return 0
}

# /**
#  * @function collect_git_evidence
#  * @description Collects Git branch name, commit hash, and working copy status.
#  * @param None
#  * @return {number} 0 on success.
#  * @example
#  *   collect_git_evidence
#  */
collect_git_evidence() {
  if [[ -z "${CURRENT_EVIDENCE_DIR}" ]]; then
    return 1
  fi
  
  local branch="not a git repo"
  local commit="none"
  local git_status="none"
  
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    branch=$(git branch --show-current)
    commit=$(git rev-parse HEAD)
    git_status=$(git status --short)
  fi
  
  local git_json
  git_json=$(jq -n \
    --arg br "${branch}" \
    --arg cmt "${commit}" \
    --arg stat "${git_status}" \
    '{branch: $br, commit: $cmt, status: ($stat | split("\n"))}')
  
  echo "${git_json}" > "${CURRENT_EVIDENCE_DIR}/git.json"
  _add_evidence_file "git.json" "git"
  return 0
}

# /**
#  * @function collect_custom_evidence
#  * @description Saves custom arbitrary JSON/text to the evidence workspace directory.
#  * @param {string} data - Custom raw data or JSON string.
#  * @return {number} 0 on success.
#  * @example
#  *   collect_custom_evidence '{"alert": "high CPU detected"}'
#  */
collect_custom_evidence() {
  if [[ -z "${CURRENT_EVIDENCE_DIR}" ]]; then
    return 1
  fi
  
  local data="$1"
  if ! echo "${data}" | jq . &>/dev/null; then
    data=$(jq -n --arg val "${data}" '{value: $val}')
  fi
  
  echo "${data}" > "${CURRENT_EVIDENCE_DIR}/custom.json"
  _add_evidence_file "custom.json" "custom"
  return 0
}

# /**
#  * @function evidence_to_json
#  * @description Consolidates all collected evidence JSON files in the current session into one unified JSON object.
#  * @param None
#  * @return {string} Consolidated JSON string.
#  * @example
#  *   local all_data
#  *   all_data=$(evidence_to_json)
#  */
evidence_to_json() {
  if [[ -z "${CURRENT_EVIDENCE_DIR}" ]]; then
    return 1
  fi
  
  local meta_file="${CURRENT_EVIDENCE_DIR}/metadata.json"
  if [[ ! -f "${meta_file}" ]]; then
    return 1
  fi
  
  local consolidated
  consolidated='{"metadata":'$(cat "${meta_file}")'}'
  
  local length
  length=$(jq '.files | length' "${meta_file}")
  local i
  for (( i = 0; i < length; i++ )); do
    local name
    name=$(jq -r ".files[${i}].name" "${meta_file}")
    local type
    type=$(jq -r ".files[${i}].type" "${meta_file}")
    if [[ -f "${CURRENT_EVIDENCE_DIR}/${name}" ]]; then
      consolidated=$(echo "${consolidated}" | jq --arg type "${type}" --argjson data "$(cat "${CURRENT_EVIDENCE_DIR}/${name}")" '. + {($type): $data}')
    fi
  done
  
  echo "${consolidated}"
}

# /**
#  * @function evidence_to_markdown
#  * @description Synthesizes the collected session evidence data into a styled Markdown report.
#  * @param None
#  * @return {string} The markdown content.
#  * @example
#  *   evidence_to_markdown
#  */
evidence_to_markdown() {
  if [[ -z "${CURRENT_EVIDENCE_DIR}" ]]; then
    return 1
  fi
  
  local report_file="${CURRENT_EVIDENCE_DIR}/report.md"
  
  {
    echo "# System Evidence Report"
    echo "Generated at: $(date)"
    echo ""
    
    if [[ -f "${CURRENT_EVIDENCE_DIR}/environment.json" ]]; then
      echo "## Environment Evidence"
      echo "- **OS**: $(jq -r '.os' "${CURRENT_EVIDENCE_DIR}/environment.json")"
      echo "- **Kernel**: $(jq -r '.kernel' "${CURRENT_EVIDENCE_DIR}/environment.json")"
      echo "- **Architecture**: $(jq -r '.arch' "${CURRENT_EVIDENCE_DIR}/environment.json")"
      echo "- **User**: $(jq -r '.user' "${CURRENT_EVIDENCE_DIR}/environment.json")"
      echo ""
    fi
    
    if [[ -f "${CURRENT_EVIDENCE_DIR}/git.json" ]]; then
      echo "## Git Evidence"
      echo "- **Branch**: $(jq -r '.branch' "${CURRENT_EVIDENCE_DIR}/git.json")"
      echo "- **Commit**: $(jq -r '.commit' "${CURRENT_EVIDENCE_DIR}/git.json")"
      echo ""
    fi
    
    if [[ -f "${CURRENT_EVIDENCE_DIR}/network.json" ]]; then
      echo "## Network Evidence"
      echo "- **Connectivity**: $(jq -r '.connectivity' "${CURRENT_EVIDENCE_DIR}/network.json")"
      echo ""
    fi
    
    if [[ -f "${CURRENT_EVIDENCE_DIR}/files.json" ]]; then
      echo "## Collected Files"
      jq -r '.[] | "* **\(.path)** (\(.size) bytes) - Hash: \(.hash)"' "${CURRENT_EVIDENCE_DIR}/files.json"
      echo ""
    fi
  } > "${report_file}"
  
  cat "${report_file}"
}

# /**
#  * @function generate_evidence_report
#  * @description Alias to evidence_to_markdown. Generates the Markdown report file.
#  * @param None
#  * @return {string} Markdown text.
#  * @example
#  *   generate_evidence_report
#  */
generate_evidence_report() {
  evidence_to_markdown
}

# /**
#  * @function evidence_archive
#  * @description Archives the evidence directory into a tarball.
#  * @param None
#  * @return {string} The path to the created tarball.
#  * @example
#  *   local archive_file
#  *   archive_file=$(evidence_archive)
#  */
evidence_archive() {
  if [[ -z "${CURRENT_EVIDENCE_DIR}" ]]; then
    return 1
  fi
  
  local parent="${CURRENT_EVIDENCE_DIR:h}"
  local dirname="${CURRENT_EVIDENCE_DIR:t}"
  local archive="${CURRENT_EVIDENCE_DIR}.tar.gz"
  
  (
    cd "${parent}"
    tar -czf "${dirname}.tar.gz" "${dirname}"
  )
  
  echo "${archive}"
}

# /**
#  * @function evidence_compare
#  * @description Compares two consolidated JSON evidence payloads and returns the JSON diff.
#  * @param {string} evidence1 - Consolidated JSON payload 1.
#  * @param {string} evidence2 - Consolidated JSON payload 2.
#  * @return {string} Diff output.
#  * @example
#  *   evidence_compare "${data1}" "${data2}"
#  */
evidence_compare() {
  local ev1="$1"
  local ev2="$2"
  diff -u <(echo "${ev1}" | jq -S .) <(echo "${ev2}" | jq -S .) 2>/dev/null
}

# /**
#  * @function evidence_validate
#  * @description Validates if a consolidated evidence JSON payload conforms to structural requirements.
#  * @param {string} data - JSON string to validate.
#  * @return {number} 0 if valid, 1 otherwise.
#  * @example
#  *   if evidence_validate "${payload}"; then
#  *     echo "Conforms to schema"
#  *   fi
#  */
evidence_validate() {
  local data="$1"
  if ! echo "${data}" | jq . &>/dev/null; then
    return 1
  fi
  echo "${data}" | jq -e '.metadata and .metadata.initialized_at' &>/dev/null
}
