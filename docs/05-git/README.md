# Git Operations — Function Index

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../05-git.md) › **05-git/** › [Runnable Example](../../examples/05_git_example.sh) › [Tests](../../tests/05-git.test.sh)

- **Source File:** [`functions/05-git.sh`](../../functions/05-git.sh)
- **Runnable Example:** [`examples/05_git_example.sh`](../../examples/05_git_example.sh)

| Function | Signature | Description |
| :--- | :--- | :--- |
| [`git_get_current_branch`](git_get_current_branch.md) | `git_get_current_branch` | Outputs the name of the current Git branch. |
| [`git_is_clean`](git_is_clean.md) | `git_is_clean` | Checks if the working tree has no uncommitted changes (both tracked and untracked). |
| [`git_get_root`](git_get_root.md) | `git_get_root` | Returns the absolute path of the root directory of the current Git repository. |
| [`git_status_message`](git_status_message.md) | `git_status_message` | Returns a short status message summary of the current Git repository. |
| [`git_commit`](git_commit.md) | `git_commit <message>` | Stages all changes and commits them with the given message. |
| [`git_push`](git_push.md) | `git_push` | Pushes the current branch to the origin remote. |
| [`git_pull`](git_pull.md) | `git_pull` | Pulls changes for the current branch from origin remote. |
| [`git_safe_pull`](git_safe_pull.md) | `git_safe_pull` | Safely pulls changes by stashing local changes, pulling, and then popping the stash. |
| [`git_branch_exists`](git_branch_exists.md) | `git_branch_exists <branch>` | Checks if a branch exists locally or on the remote origin. |
| [`git_get_commit_hash`](git_get_commit_hash.md) | `git_get_commit_hash` | Returns the full SHA-1 hash of the current HEAD commit. |
| [`git_get_commit_message`](git_get_commit_message.md) | `git_get_commit_message [hash=HEAD]` | Returns the subject line of the commit message for the specified commit hash. |
| [`git_compare_branches`](git_compare_branches.md) | `git_compare_branches [options] [<branch_a>] [<branch_b>]` | Compares two git branches, outputs a structured summary, and optionally writes a Markdown report. |
| [`git_detect_default_branch`](git_detect_default_branch.md) | `git_detect_default_branch` | Detects the repository's default branch (origin/HEAD, develop, main, or master). |
| [`git_resolve_ref`](git_resolve_ref.md) | `git_resolve_ref <branch>` | Resolves a branch name to a local ref or origin remote ref. |
| [`git_list_branches`](git_list_branches.md) | `git_list_branches [pattern]` | Lists unique local and origin branch names, optionally filtered by a glob pattern. |
| [`git_get_missed_commits`](git_get_missed_commits.md) | `git_get_missed_commits <target_branch> <source_branch>` | Outputs SHAs of commits in source_branch that have not been backported to target_branch. |
| [`git_format_commit`](git_format_commit.md) | `git_format_commit [commit_hash=HEAD]` | Formats a commit as "<short_hash> \| <date> \| <author> \| <subject>". |
| [`git_pick_branch`](git_pick_branch.md) | `git_pick_branch <prompt> [pattern]` | Prompts the user to select a branch (optionally filtered by pattern, falling back to all branches). |
| [`git_report_missed_commits`](git_report_missed_commits.md) | `git_report_missed_commits <target_branch> <release_branch> [output_file] [silent_mode=0]` | Prints (and optionally writes to Markdown) commits in release_branch missing from target_branch. |
| [`git_compare_three_branches`](git_compare_three_branches.md) | `git_compare_three_branches [options] <release_x> <release_prev> [<default_branch>]` | Compares two release branches (release/x and release/x-1) against a default branch |
| [`git_compare_commits`](git_compare_commits.md) | `git_compare_commits [options] <ref1> [<ref2>]` | Compares two Git commits, tags, or refs (defaulting the second ref to HEAD) and generates a Markdown report with commit metadata, changed files, diff stats, and optional patch diff. |
| [`git_tag_exists`](git_tag_exists.md) | `git_tag_exists <tag>` | Checks if a Git tag exists in the repository. |
| [`git_list_tags`](git_list_tags.md) | `git_list_tags [pattern]` | Lists Git tags sorted by creator date (newest first), optionally filtered by a glob pattern. |
| [`git_compare_tags`](git_compare_tags.md) | `git_compare_tags [options] [<tag_a>] [<tag_b>]` | Compares two Git tags (or auto-detects the latest two tags) and generates a colorized terminal summary and Markdown report. |
| [`git_compare_releases`](git_compare_releases.md) | `git_compare_releases [options] [<release_a>] [<release_b>]` | Compares two releases (branches like release/1.0.0 or tags like v1.0.0) to pinpoint scope creep, commit gaps, and file diffs. |
| [`git_compare_content`](git_compare_content.md) | `git_compare_content [options] <source_ref> [<target_ref>]` | Compares file or directory content between two Git refs optionally scoped by --path. |
| [`git_compare_working_tree`](git_compare_working_tree.md) | `git_compare_working_tree [options] [<base_ref>]` | Compares the working tree or staged index against HEAD (or a specified ref) and generates a Markdown report. |
| [`git_compare`](git_compare.md) | `git_compare --type <type> [options] [<source>] [<target>] [<extra>]` | Unified Git comparison dispatcher supporting branch, commit, tag, release, content, worktree, and three-way comparisons. |
