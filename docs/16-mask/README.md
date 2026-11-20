# Data Masking & Redaction — Function Index

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../16-mask.md) › **16-mask/** › [Runnable Example](../../examples/16_mask_example.sh) › [Tests](../../tests/16-mask.test.sh)

- **Source File:** [`functions/16-mask.sh`](../../functions/16-mask.sh)
- **Runnable Example:** [`examples/16_mask_example.sh`](../../examples/16_mask_example.sh)

| Function | Signature | Description |
| :--- | :--- | :--- |
| [`mask_string`](mask_string.md) | `mask_string <str> [visible_start=2] [visible_end=2] [mask_char="*"]` | Masks the middle portion of a string, keeping a specified number of leading and trailing characters visible. |
| [`mask_token`](mask_token.md) | `mask_token <token> [visible_chars=4] [mask_char="*"]` | Masks an API token, Bearer secret, or key, keeping only the first and last N characters visible. |
| [`mask_email`](mask_email.md) | `mask_email <email> [mask_char="*"]` | Masks the local part of an email address while preserving the first character and domain. |
| [`mask_phone`](mask_phone.md) | `mask_phone <phone> [visible_digits=4] [mask_char="*"]` | Masks all digits in a phone number except the last N digits, preserving formatting characters. |
| [`mask_card`](mask_card.md) | `mask_card <card_number> [visible_digits=4] [mask_char="*"]` | Masks a payment card number, keeping only the last N digits visible while preserving separators. |
| [`mask_json_fields`](mask_json_fields.md) | `mask_json_fields <json_str> <fields_csv> [mask_value="***MASKED***"]` | Masks specified sensitive fields (recursively) in a JSON string using jq. |
| [`mask_env_line`](mask_env_line.md) | `mask_env_line <line> [sensitive_keys_csv="PASSWORD,SECRET,TOKEN,KEY,AUTH"] [mask_value="***MASKED***"]` | Masks sensitive KEY=VALUE or "Header: Value" lines when the key matches any sensitive keyword. |
