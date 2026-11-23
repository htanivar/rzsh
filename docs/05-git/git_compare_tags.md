# `git_compare_tags`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../05-git.md) › [Function Index](README.md) › **`git_compare_tags`** › [Runnable Example](../../examples/05_git_example.sh) › [Tests](../../tests/05-git.test.sh)

- **Source:** [`functions/05-git.sh#L1612-L1680`](../../functions/05-git.sh#L1612-L1680)
- **Signature:** `git_compare_tags [options] [<tag_a>] [<tag_b>]`
- **Description:** Compares two Git tags (or auto-detects the latest two tags) and generates a colorized terminal summary and Markdown report.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `[options]` (`string`) | `-h/--help`, `-o/--output <file>`, `-s/--silent`, `--no-diff`. |
| `[tag_a]` (`string`) | Source/base tag (defaults to second-latest tag if 0 args). |
| `[tag_b]` (`string`) | Target tag (defaults to `HEAD` if 1 arg, or latest tag if 0 args). |

## Flags & Options

```text
  -h, --help            Show this help message.
  -o, --output <file>   Write the Markdown report to <file>.
  -s, --silent          Suppress stdout output.
      --no-diff         Omit per-file unified diffs from the report.
```

## Return / Exit Value

- {number} 0 on success, 1 on failure.

## Copy-Paste Examples

### 1. Compare Two Explicit Tags

```zsh
git_compare_tags -o "./logs/tag_report.md" v1.0.0 v1.1.0
```

### 2. Auto-Detect Latest Two Tags

```zsh
git_compare_tags --silent --output "./logs/latest_tags.md"
```

### 3. Compare a Tag Against HEAD

```zsh
git_compare_tags v1.0.0
```

---

See also the full runnable example script: [`examples/05_git_example.sh`](../../examples/05_git_example.sh).
