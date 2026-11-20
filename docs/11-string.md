# String Formatting Module Reference

**Navigation:** [README](../README.md) › [GLOSSARY](../GLOSSARY.md) › **11-string.md** › [Example](../examples/11_string_example.sh) › [Tests](../tests/11-string.test.sh)

- **Source File:** [`functions/11-string.sh`](../functions/11-string.sh)
- **Description:** Trimming, casing, padding, splitting/joining, slugification, and UUID generation.

---

## Detailed Usage Examples

### Integration Setup
To use the String Formatting module, source the configuration script via `RZSH_DIR`, which automatically imports it:

```zsh
source "${RZSH_DIR}/config/config.sh"
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
### `str_to_array`

* **Signature:** `str_to_array <string> <delimiter> [array_name=STR_ARRAY]`
* **Description:** Splits a string by the specified separator into a named Zsh array variable (defaulting to `STR_ARRAY`), preserving spaces within elements.

#### Example Code:
```zsh
local -a FRUITS
str_to_array "apple,banana,cherry" "," "FRUITS"
echo "${FRUITS[@]}"   # apple banana cherry
```

---
### `array_get_element`

* **Signature:** `array_get_element <array_name> <index_or_keyword>`
* **Description:** Retrieves a specific element from a Zsh array by 1-based index (`1`, `2`, ...), negative index (`-1` for last), or keyword (`first`, `last`). Returns `1` if the array is empty or the index is out of bounds.

#### Example Code:
```zsh
str_to_array "apple,banana,cherry" "," "FRUITS"
local first_fruit=$(array_get_element "FRUITS" "first")
local second_fruit=$(array_get_element "FRUITS" 2)
local last_fruit=$(array_get_element "FRUITS" "last")   # cherry
```

---
### `str_to_lower / str_to_upper / str_capitalize`

* **Signature:** `str_to_lower <string> / str_to_upper <string> / str_capitalize <string>`
* **Description:** Changes character casing (lowercase, uppercase, or capitalized first letter) using Zsh parameter modifiers.

#### Example Code:
```zsh
local lower=$(str_to_lower "UPPER")
local cap=$(str_capitalize "hello world")
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
### `str_random / str_uuid`

* **Signature:** `str_random [length=16] / str_uuid`
* **Description:** Generates random alphanumeric sequences or RFC 4122 v4 UUIDs.

#### Example Code:
```zsh
local rnd=$(str_random 12)
local uid=$(str_uuid)
```

---

---

## Per-Function Copy-Paste Reference

Browse dedicated per-function pages with all flags and copy-paste variations in [`docs/11-string/`](11-string/README.md), or run [`examples/11_string_example.sh`](../examples/11_string_example.sh).

| Function | Per-Function Docs & Flags | Runnable Example |
| :--- | :--- | :--- |
| `str_contains` | [Docs & Examples](11-string/str_contains.md) | [`11_string_example.sh`](../examples/11_string_example.sh) |
| `str_starts_with` | [Docs & Examples](11-string/str_starts_with.md) | [`11_string_example.sh`](../examples/11_string_example.sh) |
| `str_ends_with` | [Docs & Examples](11-string/str_ends_with.md) | [`11_string_example.sh`](../examples/11_string_example.sh) |
| `str_replace` | [Docs & Examples](11-string/str_replace.md) | [`11_string_example.sh`](../examples/11_string_example.sh) |
| `str_replace_first` | [Docs & Examples](11-string/str_replace_first.md) | [`11_string_example.sh`](../examples/11_string_example.sh) |
| `str_trim` | [Docs & Examples](11-string/str_trim.md) | [`11_string_example.sh`](../examples/11_string_example.sh) |
| `str_ltrim` | [Docs & Examples](11-string/str_ltrim.md) | [`11_string_example.sh`](../examples/11_string_example.sh) |
| `str_rtrim` | [Docs & Examples](11-string/str_rtrim.md) | [`11_string_example.sh`](../examples/11_string_example.sh) |
| `str_split` | [Docs & Examples](11-string/str_split.md) | [`11_string_example.sh`](../examples/11_string_example.sh) |
| `str_join` | [Docs & Examples](11-string/str_join.md) | [`11_string_example.sh`](../examples/11_string_example.sh) |
| `str_to_array` | [Docs & Examples](11-string/str_to_array.md) | [`11_string_example.sh`](../examples/11_string_example.sh) |
| `array_get_element` | [Docs & Examples](11-string/array_get_element.md) | [`11_string_example.sh`](../examples/11_string_example.sh) |
| `str_to_lower` | [Docs & Examples](11-string/str_to_lower.md) | [`11_string_example.sh`](../examples/11_string_example.sh) |
| `str_to_upper` | [Docs & Examples](11-string/str_to_upper.md) | [`11_string_example.sh`](../examples/11_string_example.sh) |
| `str_capitalize` | [Docs & Examples](11-string/str_capitalize.md) | [`11_string_example.sh`](../examples/11_string_example.sh) |
| `str_reverse` | [Docs & Examples](11-string/str_reverse.md) | [`11_string_example.sh`](../examples/11_string_example.sh) |
| `str_length` | [Docs & Examples](11-string/str_length.md) | [`11_string_example.sh`](../examples/11_string_example.sh) |
| `str_substring` | [Docs & Examples](11-string/str_substring.md) | [`11_string_example.sh`](../examples/11_string_example.sh) |
| `str_pad_left` | [Docs & Examples](11-string/str_pad_left.md) | [`11_string_example.sh`](../examples/11_string_example.sh) |
| `str_pad_right` | [Docs & Examples](11-string/str_pad_right.md) | [`11_string_example.sh`](../examples/11_string_example.sh) |
| `str_escape` | [Docs & Examples](11-string/str_escape.md) | [`11_string_example.sh`](../examples/11_string_example.sh) |
| `str_unescape` | [Docs & Examples](11-string/str_unescape.md) | [`11_string_example.sh`](../examples/11_string_example.sh) |
| `str_slugify` | [Docs & Examples](11-string/str_slugify.md) | [`11_string_example.sh`](../examples/11_string_example.sh) |
| `str_random` | [Docs & Examples](11-string/str_random.md) | [`11_string_example.sh`](../examples/11_string_example.sh) |
| `str_uuid` | [Docs & Examples](11-string/str_uuid.md) | [`11_string_example.sh`](../examples/11_string_example.sh) |