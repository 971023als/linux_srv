"""Run original SRV-008.py with injectable sendmail.cf / main.cf state."""
import builtins
import importlib.util
import sys
from unittest import mock

modpath, sm_case, sm_fixture, pf_case, pf_fixture = sys.argv[1:6]
real_open = builtins.open
import os
real_isfile = os.path.isfile

sm_data = real_open(sm_fixture, encoding="utf-8").read() if sm_case == "present" else ""
pf_data = real_open(pf_fixture, encoding="utf-8").read() if pf_case == "present" else ""
mo_sm = mock.mock_open(read_data=sm_data)
mo_pf = mock.mock_open(read_data=pf_data)


def selective(path, *a, **k):
    s = str(path)
    if "sendmail.cf" in s:
        return mo_sm()
    if "main.cf" in s:
        return mo_pf()
    return real_open(path, *a, **k)


def fake_isfile(p):
    s = str(p)
    if "sendmail.cf" in s:
        return sm_case == "present"
    if "main.cf" in s:
        return pf_case == "present"
    return real_isfile(p)


builtins.open = selective
os.path.isfile = fake_isfile

# SRV-008 runs all logic at module import time.
spec = importlib.util.spec_from_file_location("srvmod", modpath)
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
