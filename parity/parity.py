"""Compare original SRV-008.py (injected) vs Rust harness: stdout, log bytes, exit code."""
import subprocess
import sys
import tempfile
from pathlib import Path

BASE = Path("/tmp/srv008/parity")
HARNESS = "/tmp/srv008/target/release/harness"
PY = [sys.executable, str(BASE / "driver_py.py"), str(BASE / "SRV-008.py")]
LOGNAME = "SRV-008.py.log"

SM_FULL = ("O MaxDaemonChildren=10\nO ConnectionRateThrottle=2\nO MinFreeBlocks=100\n"
           "O MaxHeadersLength=32768\nO MaxMessageSize=1048576\n")
PF_FULL = ("message_size_limit = 102400\nheader_size_limit = 4096\n"
           "default_process_limit = 50\nlocal_destination_concurrency_limit = 2\n"
           "smtpd_recipient_limit = 100\n")

CASES = [
    ("both-missing", "missing", None, "missing", None),
    ("both-full", "present", SM_FULL, "present", PF_FULL),
    ("both-empty", "present", "", "present", ""),
    ("sm-space-warn-pf-tight-ok", "present", "O MaxDaemonChildren = 10\n",
     "present", "message_size_limit=102400\n"),
    ("sm-tight-ok-pf-collision-warn", "present", "OConnectionRateThrottle=2\n",
     "present", "header_size_limit_extra = 5\n"),
    ("sm-full-pf-partial", "present", SM_FULL,
     "present", "message_size_limit = 102400\nsmtpd_recipient_limit=100\n"),
]

failed = 0
for name, sm_case, sm_text, pf_case, pf_text in CASES:
    with tempfile.TemporaryDirectory() as td:
        td = Path(td)
        sm_file = td / "sendmail.cf.fixture"
        pf_file = td / "main.cf.fixture"
        if sm_text is not None:
            sm_file.write_text(sm_text, encoding="utf-8")
        if pf_text is not None:
            pf_file.write_text(pf_text, encoding="utf-8")
        py_dir = td / "py"
        py_dir.mkdir()
        py = subprocess.run(
            PY + [sm_case, str(sm_file), pf_case, str(pf_file)],
            cwd=py_dir, capture_output=True)
        rs = subprocess.run(
            [HARNESS,
             str(sm_file) if sm_case == "present" else "MISSING",
             str(pf_file) if pf_case == "present" else "MISSING",
             str(td / LOGNAME)],
            capture_output=True)
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
