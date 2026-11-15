"""Run original SRV-004.py with injectable systemctl/ss results."""
import importlib.util
import subprocess
import sys

modpath, service_rc, ssfile = sys.argv[1:4]
spec = importlib.util.spec_from_file_location("srvmod", modpath)
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)


class FakeCompleted:
    def __init__(self, returncode=0, stdout="", stderr=""):
        self.returncode = returncode
        self.stdout = stdout
        self.stderr = stderr


real_run = subprocess.run


def fake_run(args, **kwargs):
    if args[0] == "systemctl":
        return FakeCompleted(returncode=int(service_rc))
    if args[0] == "ss":
        with open(ssfile, encoding="utf-8") as f:
            return FakeCompleted(returncode=0, stdout=f.read())
    return real_run(args, **kwargs)


m.subprocess.run = fake_run
m.main()
