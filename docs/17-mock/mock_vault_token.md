# `mock_vault_token`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../17-mock.md) › [Function Index](README.md) › **`mock_vault_token`** › [Runnable Example](../../examples/17_mock_example.sh) › [Tests](../../tests/17-mock.test.sh)

- **Source:** [`functions/17-mock.sh#L306-L310`](../../functions/17-mock.sh#L306-L310)
- **Signature:** `mock_vault_token [prefix="hvs."] [length=24]`
- **Description:** Generates a dummy HashiCorp Vault token (e.g., hvs.<alphanumeric>).

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `[prefix="hvs."]` (`string`) | Vault token prefix. |
| `[length=24]` (`number`) | Random suffix length. |

## Return / Exit Value

- {string} Dummy Vault token.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  vtok=$(mock_vault_token)
```

---

See also the full runnable example script: [`examples/17_mock_example.sh`](../../examples/17_mock_example.sh).
