# SRV-072 Rust verification

Prerequisites: Linux, Python 3, rustc/cargo, and a separate linux_srv source checkout
containing `python/SRV-072.py` and `rust/SRV-072/` from PR #9.
No external Rust crates or Python packages are required.

From this checkout:

```sh
sh tests/srv_072/run.sh /absolute/path/to/linux_srv-source
```

The runner copies the Rust project to a temporary directory, performs an offline
locked release build, runs 5 Rust unit tests, then runs 14 Python/Rust comparisons.
It does not install a compiler, change the source checkout or modify `/etc/passwd`.
The source path may contain spaces.

13 comparisons inject a temporary passwd file at the I/O boundary, with the Python
original unchanged. The last comparison executes both actual entry points against
read-only `/etc/passwd` from distinct temporary working directories.
Comparisons assert stdout bytes, accumulated log bytes and exit code. Error-path
stderr differs (Python traceback versus Rust short error), so it is excluded.
All test logs and binaries are temporary. Successful runs remove them on exit.

Coverage: present/absent/empty/case-sensitive/substring/Unicode input, existing and
repeated logs, universal-newline handling, missing file, directory input, invalid
UTF-8, log-path directory, and default-path binary smoke.

Local result: rustc/cargo 1.99.1, Python 3.10.12, Linux x86_64. Build succeeded,
5/5 unit tests and 14/14 comparisons passed. Permission-denied, concurrent logging,
output-pipe failure, non-UTF-8 locales, CI and Docker integration remain unverified.
This tests preserved behavior, not whether the original account-check logic is a
correct security rule.
