# SRV-072 Rust pilot

Additive port of `python/SRV-072.py`. The Python file and existing runner stay unchanged.

## Build and run

`cargo build --release --offline`

Run `target/release/srv-072-pilot` from the directory where the log belongs.
The binary reads `/etc/passwd` and appends to `administrator_account_check.log`
in its current working directory, then prints the entire accumulated log.
It does not change `/etc/passwd`.

## Preserved behavior

Case-sensitive `Administrator` substring search anywhere in the file, including
non-username fields. Original Korean result messages, missing-file handling,
append mode, accumulated output, and final extra newline are preserved.
This does not establish whether an administrator account exists through LDAP/NSS.

## Validation

Local release build: rustc/cargo 1.99.1, Linux x86_64, no external crates.
Separate validation sources (not part of the main-bound source proposal):
5 Rust unit tests passed; 13 injected-input Python/Rust comparisons plus one
real-default-path binary smoke comparison passed. Compared stdout, log bytes,
and exit code; error-path stderr text was not compared.

## Limits

Rust reads UTF-8. Python decoding depends on locale/UTF-8 mode.
Rust prints a short error instead of a Python traceback. Permission-denied,
concurrent logging, output pipe errors and non-UTF-8 locales remain unverified.
No CI or Docker integration is included.
