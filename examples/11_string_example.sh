#!/usr/bin/env zsh
# examples/11_string_example.sh
# Non-technical guide to text formatting, UUIDs, pad, split/join, case changes.

source "$(dirname "$0")/../config/config.sh"
init_config

# 1. Substring contains
if str_contains "Modular Zsh Scripting" "Zsh"; then
  echo "Pattern matched!"
fi

# 2. Trimming extra spaces
local trimmed=$(str_trim "   extra space   ")
echo "Trimmed string: '${trimmed}'"

# 3. Splitting and joining text
local text="apple,banana,orange"
echo "Splitting comma separated string:"
str_split "${text}" ","

local joined=$(str_join " - " "apple" "banana" "orange")
echo "Joined string: '${joined}'"

# 4. Letter case modifications
local upper=$(str_to_upper "hello world")
echo "Uppercase representation: ${upper}"

# 5. Text padding
local padded=$(str_pad_left "7" 5 "0")
echo "Left zero padded string: ${padded}"

# 6. Slugification (URL friendly slugs)
local slug=$(str_slugify "Modern Zsh Scripting Framework!")
echo "Generated Slug: ${slug}"

# 7. Generate v4 UUID
local uuid=$(str_uuid)
echo "Generated UUID: ${uuid}"
