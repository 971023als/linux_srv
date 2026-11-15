"""Compare original SRV-004.py (injected) vs Rust harness: stdout, log bytes, exit code."""
import subprocess
import sys
import tempfile
from pathlib import Path

BASE = Path("/tmp/srv004/parity")
HARNESS = "/tmp/srv004/target/release/harness"
PY = [sys.executable, str(BASE / "driver_py.py"), str(BASE / "SRV-004.py")]
LOGNAME = "SRV-004.py.log"

SS_CLOSED = "Netid State Recv-Q Send-Q Local Address:Port Peer Address:Port\ntcp LISTEN 0 100 0.0.0.0:22 0.0.0.0:*\n"
SS_OPEN = "Netid State Recv-Q Send-Q Local Address:Port Peer Address:Port\ntcp LISTEN 0 100 0.0.0.0:25 0.0.0.0:*\n"
SS_EDGE_250 = "tcp LISTEN 0 100 0.0.0.0:250 0.0.0.0:*\ntcp LISTEN 0 100 0.0.0.0:125 0.0.0.0:*\n"
SS_EDGE_EOL = "tcp LISTEN 0 100 0.0.0.0:25\n"

CASES = [
    ("inactive-closed", "3", SS_CLOSED),
    ("active-closed", "0", SS_CLOSED),
    ("inactive-open", "3", SS_OPEN),
    ("active-open", "0", SS_OPEN),
    ("edge-250-125", "3", SS_EDGE_250),
    ("edge-eol-no-space", "3", SS_EDGE_EOL),
]

failed = 0
for name, service_rc, ss_text in CASES:
    with tempfile.TemporaryDirectory() as td:
        td = Path(td)
        ss_file = td / "ss.txt"
        ss_file.write_text(ss_text, encoding="utf-8")
        py_dir = td / "py"
        py_dir.mkdir()
        py = subprocess.run(PY + [service_rc, str(ss_file)], cwd=py_dir,
                            capture_output=True)
        rs = subprocess.run([HARNESS, "1" if service_rc == "0" else "0",
                             str(ss_file), str(td / LOGNAME)], capture_output=True)
        py_log = (py_dir / LOGNAME).read_bytes()
        rs_log = (td / LOGNAME).read_bytes()
        ok = (py.stdout == rs.stdout and py_log == rs_log
              and py.returncode == rs.returncode)
        print(f"{'PASS' if ok else 'FAIL'} {name} "
              f"(rc py={py.returncode} rs={rs.returncode})")
        if not ok:
            failed += 1
            print("  py stdout:", py.stdout[:200])
            print("  rs stdout:", rs.stdout[:200])
            print("  py log:", py_log[:200])
            print("  rs log:", rs_log[:200])
print(f"{len(CASES) - failed}/{len(CASES)} parity cases passed")
sys.exit(1 if failed else 0)
