# Evidence Collector Module Reference

- **Source File:** [`functions/99-evidences.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/99-evidences.sh)
- **Description:** Comprehensive system metadata audit incident logs collector.

---

## Detailed Usage Examples

### Integration Setup
To use the Evidence Collector module, source the configuration script via `RZSH_DIR`, which automatically imports it:

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

---

## Module Variables (Keys)

| Variable Key | Description |
| :--- | :--- |
| `EVIDENCE_DIR` | Base directory where evidence session folders are stored. |
| `CURRENT_EVIDENCE_DIR` | Path to the active timestamped evidence session directory created by `init_evidence`. |

---

## Function Signatures & Descriptions

### `init_evidence`

* **Signature:** `init_evidence`
* **Description:** Prepares session workspace directory for dumps and initializes session index metadata.

#### Example Code:
```zsh
init_evidence
```

---
### `collect_environment_evidence / collect_script_evidence / collect_network_evidence`

* **Signature:** `collect_environment_evidence / collect_script_evidence / collect_network_evidence`
* **Description:** Gathers environmental variables, system processes, DNS resolv setups, active adapters, and git history/diff information.

#### Example Code:
```zsh
collect_environment_evidence
```

---
### `collect_file_evidence`

* **Signature:** `collect_file_evidence <space_separated_files>`
* **Description:** Gathers metrics, digests, permissions, and header samples of specified files.

#### Example Code:
```zsh
collect_file_evidence "/etc/hosts /etc/resolv.conf"
```

---
### `collect_docker_evidence / collect_git_evidence / collect_custom_evidence`

* **Signature:** `collect_docker_evidence / collect_git_evidence / collect_custom_evidence <json_data>`
* **Description:** Collects docker context, Git hashes, branches, or arbitrary diagnostic reports.

#### Example Code:
```zsh
collect_custom_evidence '{"metric": "CPU peak 98%"}'
```

---
### `evidence_to_json / evidence_to_markdown / generate_evidence_report`

* **Signature:** `evidence_to_json / evidence_to_markdown / generate_evidence_report`
* **Description:** Outputs the consolidated session `metadata.json` (`evidence_to_json`), renders all collected evidence files into Markdown (`evidence_to_markdown`), or writes the compiled Markdown report directly to `${CURRENT_EVIDENCE_DIR}/report.md` (`generate_evidence_report`).

#### Example Code:
```zsh
evidence_to_markdown > report.md
local report_path=$(generate_evidence_report)
```

---
### `evidence_archive`

* **Signature:** `evidence_archive`
* **Description:** Archives the evidence collection directory into a gzip tarball, returning the archive path.

#### Example Code:
```zsh
local tarball=$(evidence_archive)
```

---
### `evidence_compare`

* **Signature:** `evidence_compare <evidence_json1> <evidence_json2>`
* **Description:** Compares two consolidated JSON payloads, returning the difference.

#### Example Code:
```zsh
evidence_compare "${first}" "${second}"
```

---
### `evidence_validate`

* **Signature:** `evidence_validate <evidence_json>`
* **Description:** Verifies if the JSON structure complies with evidence framework format.

#### Example Code:
```zsh
evidence_validate "${data}"
```

---
