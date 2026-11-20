# `dir_tree`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../10-directory.md) › [Function Index](README.md) › **`dir_tree`** › [Runnable Example](../../examples/10_directory_example.sh) › [Tests](../../tests/10-directory.test.sh)

- **Source:** [`functions/10-directory.sh#L220-L256`](../../functions/10-directory.sh#L220-L256)
- **Signature:** `dir_tree <dir>`
- **Description:** Prints a tree-like visualization of a directory structure.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `dir` (`string`) | Directory path. |

## Return / Exit Value

- {string} Tree output.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  dir_tree "/tmp/app"
```

---

See also the full runnable example script: [`examples/10_directory_example.sh`](../../examples/10_directory_example.sh).
