# Evidence Collector — Function Index

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../99-evidences.md) › **99-evidences/** › [Runnable Example](../../examples/99_evidences_example.sh) › [Tests](../../tests/99-evidences.test.sh)

- **Source File:** [`functions/99-evidences.sh`](../../functions/99-evidences.sh)
- **Runnable Example:** [`examples/99_evidences_example.sh`](../../examples/99_evidences_example.sh)

| Function | Signature | Description |
| :--- | :--- | :--- |
| [`init_evidence`](init_evidence.md) | `init_evidence` | Initializes an evidence collection session, creating a timestamped folder inside EVIDENCE_DIR. |
| [`collect_environment_evidence`](collect_environment_evidence.md) | `collect_environment_evidence` | Collects operating system, kernel, arch, env vars, user, and running process info. |
| [`collect_script_evidence`](collect_script_evidence.md) | `collect_script_evidence <args>` | Collects metadata of the executing script including name, path, and arguments. |
| [`collect_network_evidence`](collect_network_evidence.md) | `collect_network_evidence` | Collects network configuration details, DNS servers, and basic external connectivity status. |
| [`collect_file_evidence`](collect_file_evidence.md) | `collect_file_evidence <files>` | Collects size, checksums, metadata, and head contents for specified target files. |
| [`collect_docker_evidence`](collect_docker_evidence.md) | `collect_docker_evidence` | Collects running Docker containers and cached Docker images lists. |
| [`collect_git_evidence`](collect_git_evidence.md) | `collect_git_evidence` | Collects Git branch name, commit hash, and working copy status. |
| [`collect_custom_evidence`](collect_custom_evidence.md) | `collect_custom_evidence <data>` | Saves custom arbitrary JSON/text to the evidence workspace directory. |
| [`evidence_to_json`](evidence_to_json.md) | `evidence_to_json` | Consolidates all collected evidence JSON files in the current session into one unified JSON object. |
| [`evidence_to_markdown`](evidence_to_markdown.md) | `evidence_to_markdown` | Synthesizes the collected session evidence data into a styled Markdown report. |
| [`generate_evidence_report`](generate_evidence_report.md) | `generate_evidence_report` | Alias to evidence_to_markdown. Generates the Markdown report file. |
| [`evidence_archive`](evidence_archive.md) | `evidence_archive` | Archives the evidence directory into a tarball. |
| [`evidence_compare`](evidence_compare.md) | `evidence_compare <evidence1> <evidence2>` | Compares two consolidated JSON evidence payloads and returns the JSON diff. |
| [`evidence_validate`](evidence_validate.md) | `evidence_validate <data>` | Validates if a consolidated evidence JSON payload conforms to structural requirements. |
