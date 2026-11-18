#!/bin/sh
# Usage: sh run.sh /path/to/linux_srv/source-root
set -eu
SRC=$(cd "$1" && pwd)
HERE=$(cd "$(dirname "$0")" && pwd)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT HUP INT TERM
# Build a temporary copy, preserving source checkout and its target directory.
cp -R "$SRC/rust/SRV-072" "$WORK/project"
rm -rf "$WORK/project/target"
cargo build --manifest-path "$WORK/project/Cargo.toml" --release --offline --locked
cp "$HERE/unit.rs" "$HERE/driver.rs" "$WORK/"
cp "$SRC/rust/SRV-072/src/main.rs" "$WORK/pilot_source.rs"
rustc --edition 2021 --test "$WORK/unit.rs" -o "$WORK/unit-tests"
"$WORK/unit-tests"
rustc --edition 2021 "$WORK/driver.rs" -o "$WORK/driver"
python3 "$HERE/compare.py" "$SRC" --driver "$WORK/driver" --binary "$WORK/project/target/release/srv-072-pilot"
