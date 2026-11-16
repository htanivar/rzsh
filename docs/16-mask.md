# Data Masking & Redaction Module Reference

**Navigation:** [README](../README.md) › [GLOSSARY](../GLOSSARY.md) › **16-mask.md** › [Example](../examples/16_mask_example.sh) › [Tests](../tests/16-mask.test.sh)

- **Source File:** [`functions/16-mask.sh`](../functions/16-mask.sh)
- **Example Script:** [`examples/16_mask_example.sh`](../examples/16_mask_example.sh)
- **Description:** Masks sensitive strings, API/Vault tokens, email addresses, phone numbers, card numbers, JSON fields, and `KEY=VALUE` / HTTP header log lines.

---

## Integration Setup

To use the Data Masking module, source the configuration script via `RZSH_DIR`, which automatically imports all functions:

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

---

## Function Signatures & Descriptions

### `mask_string`

* **Signature:** `mask_string <str> [visible_start=2] [visible_end=2] [mask_char="*"]`
* **Description:** Masks the middle portion of a string, keeping `visible_start` leading and `visible_end` trailing characters visible. If the string is shorter than or equal to `visible_start + visible_end`, all characters are masked.

#### Example Code:
```zsh
local masked=$(mask_string "my-secret-value" 2 2)
# Output: my***********ue
```

---
### `mask_token`

* **Signature:** `mask_token <token> [visible_chars=4] [mask_char="*"]`
* **Description:** Masks an API token, Bearer secret, or Vault token, keeping only the first and last `visible_chars` characters visible.

#### Example Code:
```zsh
local masked=$(mask_token "hvs.CAESIJ1234567890abcdef" 4)
# Output: hvs.******************cdef
```

---
### `mask_email`

* **Signature:** `mask_email <email> [mask_char="*"]`
* **Description:** Masks the local part of an email address while preserving its first character and domain.

#### Example Code:
```zsh
local masked=$(mask_email "alice.smith@example.com")
# Output: a**********@example.com
```

---
### `mask_phone / mask_card`

* **Signature:** `mask_phone <phone> [visible_digits=4] [mask_char="*"]` / `mask_card <card_number> [visible_digits=4] [mask_char="*"]`
* **Description:** Masks all digits except the last `visible_digits` digits while preserving formatting characters such as `-` or spaces.

#### Example Code:
```zsh
local phone=$(mask_phone "+1-555-123-4567" 4)
local card=$(mask_card "4111-1111-1111-1234" 4)
```

---
### `mask_json_fields`

* **Signature:** `mask_json_fields <json_str> <fields_csv> [mask_value="***MASKED***"]`
* **Description:** Recursively masks specified sensitive keys in a JSON payload using `jq`.

#### Example Code:
```zsh
local safe_json=$(mask_json_fields '{"user":"alice","token":"secret123"}' "token,password")
```

---
### `mask_env_line`

* **Signature:** `mask_env_line <line> [sensitive_keys_csv="PASSWORD,SECRET,TOKEN,KEY,AUTH"] [mask_value="***MASKED***"]`
* **Description:** Masks `KEY=VALUE` or `Header: Value` lines when the key matches any sensitive keyword (case-insensitive).

#### Example Code:
```zsh
local safe_line=$(mask_env_line "DB_PASSWORD=supersecret")
# Output: DB_PASSWORD=***MASKED***
```
