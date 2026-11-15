# SRV-008 Rust pilot

Additive port of `python/SRV-008.py` (SMTP service DoS prevention settings
check). The Python file and existing runner stay unchanged.

## Build and run

`cargo build --release --offline`

Run `target/release/srv-008-pilot` from the directory where the log belongs.
The binary reads `/etc/mail/sendmail.cf` and `/etc/postfix/main.cf`, rewrites
`SRV-008.py.log` in its current working directory, then prints the log.
It does not change either configuration.

## Preserved behavior

Original Korean messages, the 32-`=` separator lines, both regex semantics:
sendmail `^O\s*SETTING=` (MULTILINE; whitespace after `O` is optional and
`=` must follow the setting name immediately, so `O MaxDaemonChildren = 10`
does not count) and postfix per-line `^SETTING\s*=` (whitespace before `=`
allowed; `header_size_limit_extra` does not count), the five-setting order in
each block, the log file name `SRV-008.py.log`, and printing the whole log to
stdout at the end are preserved.

## Validation

Local release build: rustc/cargo 1.100.0, Linux x86_64, no external crates.
Separate validation sources (not part of the main-bound source proposal):
5 Rust unit tests passed; 6 injected-input Python/Rust comparisons plus one
real-default-path binary smoke comparison passed. Compared stdout, log bytes,
and exit code; error-path stderr text was not compared.

## Limits

Real sendmail/postfix hosts, permission-denied reads, and non-UTF-8 config or
locale are untested; whitespace between a sendmail `O` and a setting name is
matched as ASCII whitespace (Python `\s` also matches Unicode spaces).
CI/docker integration untested.
