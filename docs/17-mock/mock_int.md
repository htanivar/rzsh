# `mock_int`

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../17-mock.md) › [Function Index](README.md) › **`mock_int`** › [Runnable Example](../../examples/17_mock_example.sh) › [Tests](../../tests/17-mock.test.sh)

- **Source:** [`functions/17-mock.sh#L175-L187`](../../functions/17-mock.sh#L175-L187)
- **Signature:** `mock_int [min=1] [max=1000]`
- **Description:** Generates a random integer within [min, max] inclusive.

---

## Setup (Copy-Paste Ready)

```zsh
source "${RZSH_DIR}/config/config.sh"
init_config
```

## Parameters

| Parameter | Details |
| :--- | :--- |
| `[min=1]` (`number`) | Minimum integer value. |
| `[max=1000]` (`number`) | Maximum integer value. |

## Return / Exit Value

- {number} Random integer printed to stdout.

## Copy-Paste Examples

### 1. Basic Usage

```zsh
  port=$(mock_int 8000 9000)
```

---

See also the full runnable example script: [`examples/17_mock_example.sh`](../../examples/17_mock_example.sh).
