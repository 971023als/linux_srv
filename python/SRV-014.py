import os
import subprocess

# Python dictionary for JSON data
jsonData = {
    "분류": "시스템 보안",
    "코드": "SRV-014",
    "위험도": "중간",
    "진단항목": "NFS 접근통제 설정",
    "진단결과": "(변수: 양호, 취약)",
    "현황": "Placeholder for Check-NFSAccess function",
    "대응방안": "불필요한 NFS 서비스를 사용하지 않거나, 불가피하게 사용 시 everyone 공유를 제한"
}

def bar():
    print("=" * 40)

def warn(message):
    return "WARNING: " + message

def info(message):
    return "INFO: " + message

def ok(message):
    return "OK: " + message

# Define the log file path
log_file_name = "nfs_access_control.log"  # Updated with a more descriptive name

# Clear or create the log file
with open(log_file_name, 'w') as f:
    pass

bar()

code = "[SRV-014] NFS 접근통제 미비"
with open(log_file_name, 'a') as f:
    f.write(f"{code}\n")
    f.write("[양호]: 불필요한 NFS 서비스를 사용하지 않거나, 불가피하게 사용 시 everyone 공유를 제한한 경우\n")
    f.write("[취약]: 불필요한 NFS 서비스를 사용하거나, 불가피하게 사용 시 everyone 공유를 제한하지 않는 경우\n")

bar()

# Check NFS-related processes
ps_output = subprocess.getoutput("ps -ef | grep -iE 'nfs|rpc.statd|statd|rpc.lockd|lockd' | grep -ivE 'grep|kblockd|rstatd|'")
nfs_processes = [line for line in ps_output.split('\n') if line]

if nfs_processes:
    if os.path.isfile("/etc/exports"):
        with open("/etc/exports", 'r') as file:
            exports_content = file.readlines()
            settings_warnings = []
            if any('*' in line for line in exports_content if not line.strip().startswith('#')):
                settings_warnings.append(warn("'/etc/exports' 파일에 '*' 설정이 있어 모든 클라이언트에 대한 전체 네트워크 공유를 허용합니다."))
            if any('insecure' in line for line in exports_content if not line.strip().startswith('#')):
                settings_warnings.append(warn("'insecure' 옵션이 '/etc/exports' 파일에 설정되어 있습니다."))
            if not all('root_squash' in line or 'all_squash' in line for line in exports_content if '/' in line and not line.strip().startswith('#')):
                settings_warnings.append(warn("'root_squash' 또는 'all_squash' 옵션이 '/etc/exports' 파일에 충분히 설정되지 않았습니다."))

            result = "\n".join(settings_warnings) if settings_warnings else ok("NFS 접근 설정이 적절합니다.")
            with open(log_file_name, 'a') as f:
                f.write(result + "\n")
else:
    with open(log_file_name, 'a') as f:
        f.write(ok("NFS 서비스를 사용하지 않거나, 모든 공유가 적절히 제한됩니다.") + "\n")

bar()

# Print results
with open(log_file_name, 'r') as f:
    print(f.read())
