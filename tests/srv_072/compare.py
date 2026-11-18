import os,sys,tempfile,subprocess,pathlib,json
import argparse
parser=argparse.ArgumentParser()
parser.add_argument('source_root',type=pathlib.Path)
parser.add_argument('--driver',required=True,type=pathlib.Path)
parser.add_argument('--binary',required=True,type=pathlib.Path)
args=parser.parse_args()
ORIGINAL=str((args.source_root/'python/SRV-072.py').resolve())
DRIVER=str(args.driver.resolve())
BIN=str(args.binary.resolve())
# Redirect only /etc/passwd at the I/O boundary. Original file stays unchanged.
WRAPPER='''import builtins,runpy,sys
old_open=builtins.open
def redirected(path,*args,**kwargs):
    if path == "/etc/passwd": path=sys.argv[1]
    return old_open(path,*args,**kwargs)
builtins.open=redirected
runpy.run_path(sys.argv[2],run_name="__main__")
'''
CASES=[
('present',b'Administrator:x:0:0::/:/bin/sh\n',b'',1),
('absent',b'root:x:0:0::/:/bin/sh\n',b'',1),
('empty',b'',b'',1),
('case-sensitive',b'administrator:x:0:0::/:/bin/sh\n',b'',1),
('substring',b'root:x:0:0:Administrator description:/:/bin/sh\n',b'',1),
('unicode', '사용자:x:1:1:메모:/tmp:/bin/sh\n'.encode(),b'',1),
('existing-log',b'root', '기존 기록\n'.encode(),1),
('repeat-append',b'Administrator',b'',2),
('crlf-log',b'root',b'old\r\nline\rend\n',1),
('missing-passwd',None,b'',1),
('passwd-directory','directory',b'',1),
('invalid-utf8',b'\xff',b'',1),
('log-directory',b'root','directory',1),
]
results=[]
for name,contents,seed,repeats in CASES:
 with tempfile.TemporaryDirectory() as tmp:
  base=pathlib.Path(tmp); traces=[]
  for language in ('python','rust'):
   folder=base/language; folder.mkdir(); passwd=folder/'passwd'; log=folder/'administrator_account_check.log'
   if contents=='directory': passwd.mkdir()
   elif contents is not None: passwd.write_bytes(contents)
   if seed=='directory': log.mkdir()
   elif seed: log.write_bytes(seed)
   for _ in range(repeats):
    cmd=[sys.executable,'-c',WRAPPER,str(passwd),ORIGINAL] if language=='python' else [DRIVER,str(passwd),str(log)]
    proc=subprocess.run(cmd,cwd=folder,capture_output=True,env={**os.environ,'PYTHONUTF8':'1'})
   traces.append((proc.returncode,proc.stdout,log.read_bytes() if log.is_file() else None))
  assert traces[0]==traces[1], (name,traces)
  results.append({'name':name,'parity':'PASS','code':traces[0][0],'stdout_bytes':len(traces[0][1])})
# Real binary defaults, read-only /etc/passwd, distinct temporary CWDs.
with tempfile.TemporaryDirectory() as tmp:
 traces=[]
 for language in ('python','rust'):
  folder=pathlib.Path(tmp)/language; folder.mkdir()
  cmd=[sys.executable,ORIGINAL] if language=='python' else [BIN]
  proc=subprocess.run(cmd,cwd=folder,capture_output=True,env={**os.environ,'PYTHONUTF8':'1'})
  traces.append((proc.returncode,proc.stdout,(folder/'administrator_account_check.log').read_bytes()))
 assert traces[0]==traces[1],traces
 results.append({'name':'real-binary-default-path-smoke','parity':'PASS','code':traces[0][0]})
print(json.dumps(results,ensure_ascii=False,indent=2))
print('PASS',len(results),'FAIL 0; stderr text intentionally excluded for error paths')
