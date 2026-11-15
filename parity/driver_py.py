"""Run original SRV-006.py with injectable sendmail.cf state."""
import builtins
import importlib.util
import sys
from unittest import mock

modpath, case, fixture = sys.argv[1:4]
real_isfile = None
real_open = builtins.open


def install_patches():
    import os
    global real_isfile
    real_isfile = os.path.isfile
    if case == "missing":
        os.path.isfile = lambda p: False if "sendmail" in str(p) else real_isfile(p)
    else:
        data = real_open(fixture, encoding="utf-8").read()
        mo = mock.mock_open(read_data=data)

        def selective(path, *a, **k):
            if "sendmail" in str(path):
                return mo()
            return real_open(path, *a, **k)

        builtins.open = selective
        os.path.isfile = lambda p: True if "sendmail" in str(p) else real_isfile(p)


install_patches()
# SRV-006 runs all logic at module import time.
spec = importlib.util.spec_from_file_location("srvmod", modpath)
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
