# Date & Time Utilities — Function Index

**Navigation:** [README](../../README.md) › [GLOSSARY](../../GLOSSARY.md) › [Module Overview](../08-datetime.md) › **08-datetime/** › [Runnable Example](../../examples/08_datetime_example.sh) › [Tests](../../tests/08-datetime.test.sh)

- **Source File:** [`functions/08-datetime.sh`](../../functions/08-datetime.sh)
- **Runnable Example:** [`examples/08_datetime_example.sh`](../../examples/08_datetime_example.sh)

| Function | Signature | Description |
| :--- | :--- | :--- |
| [`timestamp`](timestamp.md) | `timestamp` | Outputs the current date and time formatted according to TIMESTAMP_FORMAT. |
| [`date_now`](date_now.md) | `date_now` | Outputs the current date formatted according to DATE_FORMAT. |
| [`parse_date`](parse_date.md) | `parse_date <date_string>` | Parses a date string and prints its representation in epoch seconds. |
| [`date_add`](date_add.md) | `date_add <date> <duration>` | Adds a duration (e.g., "1 day", "2 hours") to a starting date-time. |
| [`date_subtract`](date_subtract.md) | `date_subtract <date> <duration>` | Subtracts a duration (e.g., "1 day", "2 hours") from a starting date-time. |
| [`date_diff`](date_diff.md) | `date_diff <date1> <date2>` | Calculates the difference (in seconds) between two dates. |
| [`date_format`](date_format.md) | `date_format <date> <format>` | Formats a date string using the specified format. |
| [`timezone_convert`](timezone_convert.md) | `timezone_convert <date> <from_tz> <to_tz>` | Converts a date string from one timezone to another. |
| [`is_valid_date`](is_valid_date.md) | `is_valid_date <date>` | Checks if a date string is parseable and valid. |
| [`date_range`](date_range.md) | `date_range <start> <end> [interval="1 day"]` | Prints a range of dates from start to end with the specified interval. |
| [`format_duration`](format_duration.md) | `format_duration <seconds>` | Formats a number of seconds into a human-readable duration (e.g., 2h 15m 5s). |
