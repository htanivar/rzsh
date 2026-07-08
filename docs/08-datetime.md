# Time & Duration Module Reference

- **Source File:** [`functions/08-datetime.sh`](file:///home/ubuntu/code/github/raviautopilot/rWork/shared/rzsh/functions/08-datetime.sh)
- **Description:** Date additions, subtractions, ranges, durations, and Unix conversions.

---

## Detailed Usage Examples

### Integration Setup
To use the Time & Duration module, you only need to source the configuration script, which automatically imports it:

```zsh
source ./config/config.sh
init_config
```

---

## Function Signatures & Descriptions

### `timestamp`

* **Signature:** `timestamp`
* **Description:** Outputs the current epoch time in seconds.

#### Example Code:
```zsh
local start_sec=$(timestamp)
```

---
### `date_now`

* **Signature:** `date_now`
* **Description:** Outputs the current date formatted in DATE_FORMAT.

#### Example Code:
```zsh
local today=$(date_now)
```

---
### `parse_date`

* **Signature:** `parse_date <date_string>`
* **Description:** Converts a date string (YYYY-MM-DD HH:MM:SS) to Unix epoch seconds.

#### Example Code:
```zsh
local epoch=$(parse_date "2026-07-08 12:00:00")
```

---
### `date_add / date_subtract`

* **Signature:** `date_add <date_string> <quantity> <unit> / date_subtract <date_string> <quantity> <unit>`
* **Description:** Adds or subtracts offsets (days, hours, minutes, seconds) to a date string.

#### Example Code:
```zsh
local next_week=$(date_add "$(date_now)" 7 "days")
```

---
### `date_diff`

* **Signature:** `date_diff <date_string1> <date_string2>`
* **Description:** Calculates the absolute difference in seconds between two date strings.

#### Example Code:
```zsh
local seconds=$(date_diff "2026-07-01" "2026-07-08")
```

---
### `date_format`

* **Signature:** `date_format <epoch_seconds> <format_string>`
* **Description:** Formats a Unix timestamp to a custom string representation.

#### Example Code:
```zsh
local formatted=$(date_format 1774849200 "%A, %B %d, %Y")
```

---
### `is_valid_date`

* **Signature:** `is_valid_date <date_string>`
* **Description:** Checks if the date string represents a valid real date calendar day.

#### Example Code:
```zsh
is_valid_date "2026-02-29"
```

---
### `date_range`

* **Signature:** `date_range <start_date> <end_date> [step_days]`
* **Description:** Outputs all dates between start and end inclusive, separated by newlines.

#### Example Code:
```zsh
date_range "2026-07-01" "2026-07-05"
```

---
### `format_duration`

* **Signature:** `format_duration <seconds>`
* **Description:** Converts seconds into a human-readable duration string (e.g. 1h 25m 30s).

#### Example Code:
```zsh
local duration=$(format_duration 5130)
```

---
