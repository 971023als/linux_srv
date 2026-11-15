# SRV-006 Rust pilot

Additive port of `python/SRV-006.py` (SMTP service log level check).
The Python file and existing runner stay unchanged.

## Build and run

`cargo build --release --offline`

Run `target/release/srv-006-pilot` from the directory where the log belongs.
The binary reads `/etc/mail/sendmail.cf`, rewrites `SRV-006.py.log` in its
current working directory, then prints the log. It does not change the
sendmail configuration.

## Preserved behavior

Original Korean result messages, first `O LogLevel`-prefixed line wins, the
third whitespace token shown verbatim in the message (`09` stays `09`), level
>= 9 means OK, missing setting means WARN with `미설정`, missing file means
INFO, the 40-`=` separator lines, the double-quoted title line, the log file
name `SRV-006.py.log`, and printing the whole log to stdout at the end are
preserved. A non-numeric token mirrors the original crash path: exit code 1,
empty stdout, and the partial log written before the check (only stderr
differs: short error text instead of a Python traceback).

## Validation

Local release build: rustc/cargo 1.100.0, Linux x86_64, no external crates.
Separate validation sources (not part of the main-bound source proposal):
5 Rust unit tests passed; 7 injected-input Python/Rust comparisons (including
the crash path) plus one real-default-path binary smoke comparison passed.
Compared stdout, log bytes, and exit code; error-path stderr text was not
compared.

## Limits

Real sendmail hosts, permission-denied reads, and non-UTF-8 config or locale
are untested. CI/docker integration untested.
