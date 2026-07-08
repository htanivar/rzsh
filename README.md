# Zsh Modular Scripting Framework

A highly modular, reusable, and robust shell scripting framework built natively on Zsh 5.8+. This repository provides 15 unified modules with strict coding standards: JSDoc documentation, isolated scoping (no global leakage), robust path and error checks, and 100% unit-tested correctness.

## Table of Contents
- [Getting Started](#getting-started)
- [Framework Directory Structure](#framework-directory-structure)
- [Module Reference Directory](#module-reference-directory)
- [Unit Testing](#unit-testing)
- [Frequently Asked Questions (FAQ)](#frequently-asked-questions-faq)
- [Future Improvements](#future-improvements)

## Getting Started

To use this framework in any Zsh shell environment, source the configuration manager first, then source the required functional modules:

```zsh
# Sourcing the config and core logging modules
source ./config/config.sh
init_config

source ./functions/01-logs.sh
source ./functions/02-errors.sh

log_info "Workspace initialized successfully."
```

## Framework Directory Structure
```
.
├── README.md               # Main documentation
├── README.sh               # Executable console help manual
├── test.sh                 # Unit test runner
├── config/
│   └── config.sh           # Global environment variables
├── functions/              # Modular functional scripts
│   ├── 01-logs.sh
│   ├── 02-errors.sh
│   └── ... (modules 01-14)
├── tests/                  # Assertion-based unit tests
│   ├── test_helpers.sh
│   ├── 01-logs.test.sh
│   └── ... (tests 01-14)
└── docs/                   # Comprehensive usage guides
    ├── 00-config.md
    ├── 01-logs.md
    └── ... (modules 01-14)
```

## Module Reference Directory

Here is the index of available modules. Click on any module link to view a comprehensive usage guide containing detailed examples and api signatures:

| ID | Module Name | Source File | Usage Guide |
|---|---|---|---|
| 00 | Global Configuration | [`config/config.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/config/config.sh) | [Usage Documentation](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/00-config.md) |
| 01 | Logging Utility | [`functions/01-logs.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/01-logs.sh) | [Usage Documentation](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/01-logs.md) |
| 02 | Error Handling | [`functions/02-errors.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/02-errors.sh) | [Usage Documentation](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/02-errors.md) |
| 03 | File Navigation & Git Checks | [`functions/03-navigation.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/03-navigation.sh) | [Usage Documentation](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/03-navigation.md) |
| 04 | Input & Format Validation | [`functions/04-validation.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/04-validation.sh) | [Usage Documentation](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/04-validation.md) |
| 05 | Git Operations | [`functions/05-git.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/05-git.sh) | [Usage Documentation](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/05-git.md) |
| 06 | HTTP Client Wrapper | [`functions/06-curl.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/06-curl.sh) | [Usage Documentation](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/06-curl.md) |
| 07 | Interactive Prompts | [`functions/07-user-actions.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/07-user-actions.sh) | [Usage Documentation](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/07-user-actions.md) |
| 08 | Time & Duration | [`functions/08-datetime.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/08-datetime.sh) | [Usage Documentation](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/08-datetime.md) |
| 09 | File Utilities | [`functions/09-file.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/09-file.sh) | [Usage Documentation](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/09-file.md) |
| 10 | Directory Management | [`functions/10-directory.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/10-directory.sh) | [Usage Documentation](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/10-directory.md) |
| 11 | String Formatting | [`functions/11-string.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/11-string.sh) | [Usage Documentation](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/11-string.md) |
| 12 | JSON Parsing | [`functions/12-json.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/12-json.sh) | [Usage Documentation](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/12-json.md) |
| 13 | JSON Web Tokens | [`functions/13-jwt.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/13-jwt.sh) | [Usage Documentation](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/13-jwt.md) |
| 14 | Evidence Collector | [`functions/14-evidence.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/14-evidence.sh) | [Usage Documentation](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/docs/14-evidence.md) |

## Unit Testing

The framework includes a custom test runner with assertions (`assert_equals`, `assert_true`, `assert_false`) built natively. Since the system might have shell-restrictive configurations, execute the test runner via the relocatable local Zsh binary:

```bash
PATH="/home/ubuntu/.local/bin:$PATH" ./test.sh
```

## Frequently Asked Questions (FAQ)

### Why are JSDoc blocks commented out with `# `?
In Zsh, `/**` behaves as a recursive glob operator by default. If a comment starts with `/**` without being prepended with `# `, Zsh tries to scan the filesystem for matching files, triggering `no matches found` or permission errors. Prepending `# ` treats the block as comments.

### Why is `local path` avoided in Zsh?
In Zsh, `path` is a special array tied directly to the `PATH` environment variable. Declaring `local path` and assigning a value (e.g. `.user.name`) modifies the shell's command resolution path, instantly breaking external calls like `jq`. Always use `json_path` or alternative names.

### Why is `local status` avoided in Zsh?
In Zsh, `status` is a read-only variable alias to `$?`. Trying to declare `local status` causes Zsh to exit immediately with a `read-only variable: status` error. Use `exit_code` or `retry_status` instead.

## Future Improvements
1. **TOML/YAML Native Parsers:** Integrate a lightweight shell-native TOML reader.
2. **Interactive Elements:** Add support for terminal spinners and progression animations.
3. **Advanced Log Rotation:** Auto-archiving logs that exceed 10MB in the background.
4. **Mocked HTTP Client Tests:** Run a tiny local HTTP server during unit tests instead of relying on external curls.
