# String Manipulation — Function Index

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../11-string.md) › **11-string/** › [Runnable Example](../../examples/11_string_example.sh) › [Tests](../../tests/11-string.test.sh)

- **Source File:** [`functions/11-string.sh`](../../functions/11-string.sh)
- **Runnable Example:** [`examples/11_string_example.sh`](../../examples/11_string_example.sh)

| Function | Signature | Description |
| :--- | :--- | :--- |
| [`str_contains`](str_contains.md) | `str_contains <str> <substr>` | Checks if a substring is contained within a string. |
| [`str_starts_with`](str_starts_with.md) | `str_starts_with <str> <prefix>` | Checks if a string starts with a specified prefix. |
| [`str_ends_with`](str_ends_with.md) | `str_ends_with <str> <suffix>` | Checks if a string ends with a specified suffix. |
| [`str_replace`](str_replace.md) | `str_replace <str> <search> <replace>` | Replaces all occurrences of a search term with a replacement term in a string. |
| [`str_replace_first`](str_replace_first.md) | `str_replace_first <str> <search> <replace>` | Replaces only the first occurrence of a search term with a replacement term. |
| [`str_trim`](str_trim.md) | `str_trim <str>` | Trims leading and trailing whitespace from a string. |
| [`str_ltrim`](str_ltrim.md) | `str_ltrim <str>` | Trims leading whitespace from a string. |
| [`str_rtrim`](str_rtrim.md) | `str_rtrim <str>` | Trims trailing whitespace from a string. |
| [`str_split`](str_split.md) | `str_split <str> <delimiter>` | Splits a string by a delimiter and outputs each piece on a ask line. |
| [`str_join`](str_join.md) | `str_join <delimiter> <args>` | Joins an array of strings or multiple arguments with the specified delimiter. |
| [`str_to_array`](str_to_array.md) | `str_to_array <str> <delimiter> [array_name=STR_ARRAY]` | Splits a string by a separator/delimiter into a Zsh array variable. |
| [`array_get_element`](array_get_element.md) | `array_get_element <array_name> <index>` | Retrieves a specific element from a Zsh array by 1-based index, negative index (e.g. -1), or keyword ('first', 'last'). |
| [`str_to_lower`](str_to_lower.md) | `str_to_lower <str>` | Converts a string to lowercase. |
| [`str_to_upper`](str_to_upper.md) | `str_to_upper <str>` | Converts a string to uppercase. |
| [`str_capitalize`](str_capitalize.md) | `str_capitalize <str>` | Capitalizes the first letter of each word in a string. |
| [`str_reverse`](str_reverse.md) | `str_reverse <str>` | Reverses the character order of a string. |
| [`str_length`](str_length.md) | `str_length <str>` | Prints the character length of a string. |
| [`str_substring`](str_substring.md) | `str_substring <str> <offset> <length>` | Returns a portion of a string starting at 0-based offset with specified length. |
| [`str_pad_left`](str_pad_left.md) | `str_pad_left <str> <len> [pad=" "]` | Pads the left side of a string to a certain length with a padding string. |
| [`str_pad_right`](str_pad_right.md) | `str_pad_right <str> <len> [pad=" "]` | Pads the right side of a string to a certain length with a padding string. |
| [`str_escape`](str_escape.md) | `str_escape <str>` | Shell-escapes a string using Zsh quoting mechanics. |
| [`str_unescape`](str_unescape.md) | `str_unescape <str>` | Unescapes a shell-escaped string. |
| [`str_slugify`](str_slugify.md) | `str_slugify <str>` | Converts a string to a lowercase URL-safe slug representation. |
| [`str_random`](str_random.md) | `str_random [len=16]` | Generates a random alphanumeric string of the specified length. |
| [`str_uuid`](str_uuid.md) | `str_uuid` | Generates a standard UUID version 4 (all lowercase). |
