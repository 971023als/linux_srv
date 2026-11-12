# SRV-001 Rust pilot

Additive port of `python/SRV-001.py` (SNMP Get Community string check).
The Python file and existing runner stay unchanged.

## Build and run

`cargo build --release --offline`

Run `target/release/srv-001-pilot` from the directory where the log belongs.
The binary runs `ps -ef`, reads `/etc/snmp/snmpd.conf`, rewrites
`SRV-001.py.log` in its current working directory, then prints the log.
It does not change the snmpd configuration.

## Preserved behavior

`ps -ef | grep -i snmp | grep -v grep | wc -l` service check (case-insensitive
"snmp" match, case-sensitive "grep" lines excluded), original Korean result
messages, log header and separator layout, three separator lines printed
before the log dump, truncate-and-rewrite log mode, and the log file name
`SRV-001.py.log` are preserved.

## Validation

Local release build: rustc/cargo 1.100.0, Linux x86_64, no external crates.
Separate validation sources (not part of the main-bound source proposal):
5 Rust unit tests passed; 6 injected-input Python/Rust comparisons plus one
real-default-path binary smoke comparison passed. Compared stdout, log bytes,
and exit code; error-path stderr text was not compared.

## Limits

Rust reads UTF-8. Python decoding depends on locale/UTF-8 mode.
Rust prints a short error instead of a Python traceback. A running snmpd on
the host, permission-denied, non-UTF-8 config or locale, and CI/Docker
integration remain unverified.
