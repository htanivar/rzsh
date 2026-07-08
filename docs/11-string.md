# String Formatting Module Reference

- **Source File:** [`functions/11-string.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/11-string.sh)
- **Description:** Trimming, casing, padding, splitting/joining, slugification, and UUID generation.

---

## Detailed Usage Examples

### Integration Setup
To use the String Formatting module, you only need to source the configuration script, which automatically imports it:

```zsh
source ./config/config.sh
init_config
```

---

## Function Signatures & Descriptions

### `str_contains`

* **Signature:** `str_contains <string> <substring>`
* **Description:** Returns 0 if substring is present, 1 otherwise.

#### Example Code:
```zsh
str_contains "foobar" "bar"
```

---
### `str_starts_with / str_ends_with`

* **Signature:** `str_starts_with <string> <prefix> / str_ends_with <string> <suffix>`
* **Description:** Verifies prefix or suffix matching.

#### Example Code:
```zsh
str_starts_with "v1.0.0" "v"
```

---
### `str_replace / str_replace_first`

* **Signature:** `str_replace <string> <search> <replace> / str_replace_first <string> <search> <replace>`
* **Description:** Replaces all or first occurrence of search term.

#### Example Code:
```zsh
local output=$(str_replace "abc-abc" "b" "x")
```

---
### `str_trim / str_ltrim / str_rtrim`

* **Signature:** `str_trim <string> / str_ltrim <string> / str_rtrim <string>`
* **Description:** Trims whitespace using local Zsh extendedglob.

#### Example Code:
```zsh
local val=$(str_trim "  clean me  ")
```

---
### `str_split / str_join`

* **Signature:** `str_split <string> <delimiter> / str_join <delimiter> <val1> <val2> ...`
* **Description:** Splits a string by delimiter (outputting newlines) or joins items using delimiter.

#### Example Code:
```zsh
local array=($(str_split "a,b,c" ","))
```

---
### `str_to_lower / str_to_upper`

* **Signature:** `str_to_lower <string> / str_to_upper <string>`
* **Description:** Changes character casing using Zsh parameter modifiers.

#### Example Code:
```zsh
local lower=$(str_to_lower "UPPER")
```

---
### `str_reverse / str_length / str_substring`

* **Signature:** `str_reverse <string> / str_length <string> / str_substring <string> <start> <length>`
* **Description:** Performs basic character metrics and modifications.

#### Example Code:
```zsh
local sub=$(str_substring "antigravity" 5 7)
```

---
### `str_pad_left / str_pad_right`

* **Signature:** `str_pad_left <string> <width> [char] / str_pad_right <string> <width> [char]`
* **Description:** Pads a string to a given width.

#### Example Code:
```zsh
local padded=$(str_pad_left "42" 5 "0")
```

---
### `str_escape / str_unescape`

* **Signature:** `str_escape <string> / str_unescape <string>`
* **Description:** Escapes/unescapes shell-sensitive characters.

#### Example Code:
```zsh
local safe=$(str_escape "hello \"world\"")
```

---
### `str_slugify`

* **Signature:** `str_slugify <string>`
* **Description:** Converts string to a clean URL-friendly slug.

#### Example Code:
```zsh
local slug=$(str_slugify "Zsh Framework 1.0!")
```

---
### `str_random_alphanumeric / str_uuid`

* **Signature:** `str_random_alphanumeric <length> / str_uuid`
* **Description:** Generates random alphanumeric sequences or RFC 4122 v4 UUIDs.

#### Example Code:
```zsh
local uid=$(str_uuid)
```

---
