"""Run original SRV-002.py with injectable service state and snmpd.conf content."""
import builtins
import importlib.util
import sys
from unittest import mock

modpath, mode, confcase, conffile = sys.argv[1:5]
spec = importlib.util.spec_from_file_location("srvmod", modpath)
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
m.check_snmp_service = lambda: mode == "running"
real_isfile = m.os.path.isfile
real_open = builtins.open
if confcase == "missing":
    m.os.path.isfile = lambda p: False if "snmpd" in str(p) else real_isfile(p)
elif confcase == "present":
    data = real_open(conffile, encoding="utf-8").read()
    mo = mock.mock_open(read_data=data)
    def selective(path, *a, **k):
        if "snmpd" in str(path):
            return mo()
        return real_open(path, *a, **k)
    builtins.open = selective
    m.os.path.isfile = lambda p: True if "snmpd" in str(p) else real_isfile(p)
m.main()
