#!/usr/bin/env zsh
# examples/16_mask_example.sh
# Breadcrumb: README.md -> GLOSSARY.md -> docs/16-mask.md -> examples/16_mask_example.sh -> tests/16-mask.test.sh
# Non-technical guide to masking secrets, tokens, PII, JSON fields, and config lines.
[ -z "${ZSH_VERSION:-}" ] && exec zsh "$0" "$@"

if [[ -z "${RZSH_DIR:-}" ]]; then
  printf '[WARN] RZSH_DIR is not set. Please set export RZSH_DIR="%s" in your environment (e.g., ~/.zshrc).\n' "${0:A:h:h}" >&2
  export RZSH_DIR="${0:A:h:h}"
fi

source "${RZSH_DIR}/config/config.sh"
init_config

echo "=== Data Masking & Redaction Examples ==="

# 1. Generic string masking
echo "Masked string: $(mask_string "my-secret-value" 2 2)"

# 2. Token masking
echo "Masked token:  $(mask_token "hvs.CAESIJ1234567890abcdef" 4)"

# 3. Email, phone, and card masking
echo "Masked email:  $(mask_email "alice.smith@example.com")"
echo "Masked phone:  $(mask_phone "+1-555-123-4567" 4)"
echo "Masked card:   $(mask_card "4111-1111-1111-1234" 4)"

# 4. Masking sensitive JSON fields
sample_json='{"user":"alice","auth":{"token":"secret-jwt","role":"admin"},"password":"hunter2"}'
echo "Masked JSON:   $(mask_json_fields "${sample_json}" "token,password")"

# 5. Masking sensitive environment / header lines
echo "Masked env:    $(mask_env_line "DB_PASSWORD=supersecret")"
echo "Safe env:      $(mask_env_line "LOG_LEVEL=INFO")"
echo "Masked header: $(mask_env_line "Authorization: Bearer secret-token")"
