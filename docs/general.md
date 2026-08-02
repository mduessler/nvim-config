# General

## Commands

### Logging

The following user commands help you inspect log files directly from Neovim.

- **LOGOpen** — Opens the current log file in a new tab.\
  Usage: `:LOGOpen [N]`
  - N (Optional) — specify which log file to use.
- **LOGLast** — Prints the last logging message from the log file and writes
  it to the clipboard.\
  Usage: `:LOGLast [N]`
  - N (Optional) — specify which log file to use.
- **LOGLine** — Prints the logging message of line *N* and writes it to
  the clipboard.\
  Usage: `:LOGLine N [M]`
  - N — line number from which the message is printed.
  - M (Optional) — specify which log file to use.
