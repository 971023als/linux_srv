"""Compare original SRV-001.py (injected) vs Rust harness: stdout, log bytes, exit code."""
import subprocess
import sys
import tempfile
from pathlib import Path

BASE = Path("/tmp/srv001/parity")
HARNESS = "/tmp/srv001/target/release/harness"
PY = [sys.executable, str(BASE / "driver_py.py"), str(BASE / "SRV-001.py")]

PS_NONE = "root 1 0.0 ?\nuser 44 0.0 bash\n"
PS_SNMP = "root 1 0.0 ?\nsnmp 99 0.0 /usr/sbin/snmpd -f\n"
CASES = [
    ("not-running", "notrunning", "na", PS_NONE, None),
    ("weak-public", "running", "present", PS_SNMP, "rocommunity public\n"),
    ("weak-PRIVATE-upper", "running", "present", PS_SNMP, "rwcommunity PRIVATE\n"),
    ("clean-conf", "running", "present", PS_SNMP, "rocommunity S3cure-String!\n"),
    ("missing-conf", "running", "missing", PS_SNMP, None),
    ("comment-public", "running", "present", PS_SNMP, "# default public not changed\nrocommunity S3cure!\n"),
]

failed = 0
for name, mode, confcase, ps_text, conf_text in CASES:
    with tempfile.TemporaryDirectory() as td:
        td = Path(td)
        ps_file = td / "ps.txt"
        ps_file.write_text(ps_text, encoding="utf-8")
        conf_file = td / "snmpd.conf.fixture"
        # Rust harness gets the same content at a path that exists for 'present';
        # for 'missing' it gets the real default path, which does not exist here,
        # so its NotFound message matches Python's hardcoded /etc/snmp/snmpd.conf.
        rs_conf = "/etc/snmp/snmpd.conf"
        if conf_text is not None:
            conf_file.write_text(conf_text, encoding="utf-8")
            rs_conf = str(td / "snmpd.conf")
            Path(rs_conf).write_text(conf_text, encoding="utf-8")
        py_dir = td / "py"
        py_dir.mkdir()
        py = subprocess.run(PY + [mode, confcase, str(conf_file)], cwd=py_dir,
                            capture_output=True)
        rs = subprocess.run([HARNESS, str(ps_file), rs_conf,
                             str(td / "SRV-001.py.log")], capture_output=True)
        py_log = (py_dir / "SRV-001.py.log").read_bytes()
        rs_log = (td / "SRV-001.py.log").read_bytes()
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
