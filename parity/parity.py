"""Compare original SRV-006.py (injected) vs Rust harness: stdout, log bytes, exit code."""
import subprocess
import sys
import tempfile
from pathlib import Path

BASE = Path("/tmp/srv006/parity")
HARNESS = "/tmp/srv006/target/release/harness"
PY = [sys.executable, str(BASE / "driver_py.py"), str(BASE / "SRV-006.py")]
LOGNAME = "SRV-006.py.log"

CASES = [
    ("no-file", "missing", None),
    ("level-9", "present", "O LogLevel 9\n"),
    ("level-3", "present", "O LogLevel 3\n"),
    ("no-setting", "present", "# sendmail cf\nO SomeOther 1\n"),
    ("first-wins", "present", "O LogLevel 3\nO LogLevel 9\n"),
    ("leading-zero", "present", "O LogLevel 09\n"),
    ("crash-bad-token", "present", "O LogLevel abc\n"),
]

failed = 0
for name, case, conf_text in CASES:
    with tempfile.TemporaryDirectory() as td:
        td = Path(td)
        conf_file = td / "sendmail.cf.fixture"
        if conf_text is not None:
            conf_file.write_text(conf_text, encoding="utf-8")
        py_dir = td / "py"
        py_dir.mkdir()
        py = subprocess.run(PY + [case, str(conf_file)], cwd=py_dir,
                            capture_output=True)
        rs_arg1 = str(conf_file) if case == "present" else "MISSING"
        rs = subprocess.run([HARNESS, rs_arg1, str(td / LOGNAME)],
                            capture_output=True)
        py_log = (py_dir / LOGNAME).read_bytes()
        rs_log = (td / LOGNAME).read_bytes()
        # stderr is not compared: Python traceback vs short error text.
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
