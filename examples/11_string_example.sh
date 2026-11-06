#!/usr/bin/env zsh
# examples/11_string_example.sh
# Non-technical guide to text formatting, UUIDs, pad, split/join, case changes.
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${0:A:h:h}" >&2
  export RZSH_DIR="${0:A:h:h}"
fi

source "${RZSH_DIR}/config/config.sh"
init_config

# 1. Substring contains
if str_contains "Modular Zsh Scripting" "Zsh"; then
  echo "Pattern matched!"
fi

# 2. Trimming extra spaces
trimmed=$(str_trim "   extra space   ")
echo "Trimmed string: '${trimmed}'"

# 3. Splitting and joining text
text="apple,banana,orange"
echo "Splitting comma separated string:"
str_split "${text}" ","

joined=$(str_join " - " "apple" "banana" "orange")
echo "Joined string: '${joined}'"

# 4. Letter case modifications
upper=$(str_to_upper "hello world")
echo "Uppercase representation: ${upper}"

# 5. Text padding
padded=$(str_pad_left "7" 5 "0")
echo "Left zero padded string: ${padded}"

# 6. Slugification (URL friendly slugs)
slug=$(str_slugify "Modern Zsh Scripting Framework!")
echo "Generated Slug: ${slug}"

# 7. Generate v4 UUID
uuid=$(str_uuid)
echo "Generated UUID: ${uuid}"
