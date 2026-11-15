# SRV-004 Rust pilot

Additive port of `python/SRV-004.py` (unnecessary SMTP service check).
The Python file and existing runner stay unchanged.

## Build and run

`cargo build --release --offline`

Run `target/release/srv-004-pilot` from the directory where the log belongs.
The binary runs `systemctl is-active --quiet postfix` and `ss -tuln`, rewrites
`SRV-004.py.log` in its current working directory, then prints the log.
It does not change the SMTP configuration.

## Preserved behavior

Original Korean result messages, service check via the
`systemctl is-active --quiet postfix` exit code, port check via the literal
`":25 "` substring (a trailing space is required, so `:250` or `:125` do not
count), the 50-dash separator lines, truncate-then-write log mode, the log
file name `SRV-004.py.log`, and printing the whole log to stdout at the end
are preserved.

## Validation

Local release build: rustc/cargo 1.100.0, Linux x86_64, no external crates.
Separate validation sources (not part of the main-bound source proposal):
5 Rust unit tests passed; 6 injected-input Python/Rust comparisons plus one
real-default-path binary smoke comparison passed. Compared stdout, log bytes,
and exit code; error-path stderr text was not compared.

## Limits

Hosts where the `systemctl` or `ss` binaries are missing produce a short
error message instead of a Python traceback (exit code 1 in both).
Non-UTF-8 `ss` output is decoded lossily. CI/docker integration untested.
