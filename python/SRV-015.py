import subprocess
import os

# Python dictionary for JSON data
jsonData = {
    "분류": "시스템 보안",
    "코드": "SRV-015",
    "위험도": "중간",
    "진단항목": "NFS 서비스 실행 여부",
    "진단결과": "(변수: 양호, 취약)",
    "현황": "Placeholder for Get-NFSDaemonStatus function",
    "대응방안": "불필요한 NFS 서비스 관련 데몬을 비활성화 하세요."
}

def bar():
    print("=" * 40)

def warn(message):
    return "WARNING: " + message

def ok(message):
    return "OK: " + message

# Define the log file path
log_file_name = os.path.basename(__file__) + '.log'

# Clear or create the log file
with open(log_file_name, 'w') as f:
    pass

bar()

code = "[SRV-015] 불필요한 NFS 서비스 실행"
with open(log_file_name, 'a') as f:
    f.write(f"{code}\n")
    f.write("[양호]: 불필요한 NFS 서비스 관련 데몬이 비활성화 되어 있는 경우\n")
    f.write("[취약]: 불필요한 NFS 서비스 관련 데몬이 활성화 되어 있는 경우\n")

bar()

# Check for NFS service-related daemons
ps_output = subprocess.getoutput("ps -ef | grep -iE 'nfs|rpc.statd|statd|rpc.lockd|lockd' | grep -ivE 'grep|kblockd|rstatd|'")
nfs_daemons = [line for line in ps_output.split('\n') if line]

if nfs_daemons:
    result = warn("불필요한 NFS 서비스 관련 데몬이 실행 중입니다.")
else:
    result = ok("불필요한 NFS 서비스 관련 데몬이 비활성화 되어 있습니다.")

with open(log_file_name, 'a') as f:
    f.write(result + "\n")

bar()

# Print results
with open(log_file_name, 'r') as f:
    print(f.read())
print()
