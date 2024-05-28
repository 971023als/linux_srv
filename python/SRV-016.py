import os
import subprocess

# Python dictionary for JSON data
jsonData = {
    "분류": "시스템 보안",
    "코드": "SRV-016",
    "위험도": "중간",
    "진단항목": "RPC 서비스 실행 여부",
    "진단결과": "(변수: 양호, 취약)",
    "현황": "Placeholder for Get-RPCServiceStatus function",
    "대응방안": "불필요한 RPC 서비스를 비활성화 하세요."
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

code = "[SRV-016] 불필요한 RPC서비스 활성화"
with open(log_file_name, 'a') as f:
    f.write(f"{code}\n")
    f.write("[양호]: 불필요한 RPC 서비스가 비활성화 되어 있는 경우\n")
    f.write("[취약]: 불필요한 RPC 서비스가 활성화 되어 있는 경우\n")

bar()

# RPC 관련 서비스 목록
rpc_services = ["rpc.cmsd", "rpc.ttdbserverd", "sadmind", "rusersd", "walld", "sprayd", "rstatd", "rpc.nisd", "rexd", "rpc.pcnfsd", "rpc.statd", "rpc.ypupdated", "rpc.rquotad", "kcms_server", "cachefsd"]

found_services = []

# Check services in xinetd and inetd configurations
def check_services(service_files, services_list):
    found = []
    for service in services_list:
        for service_file in service_files:
            if os.path.isfile(service_file):
                with open(service_file, 'r') as f:
                    content = f.read().lower()
                    if service in content and 'disable = no' in content:
                        found.append(service)
    return found

xinetd_services = check_services([f"/etc/xinetd.d/{s}" for s in rpc_services], rpc_services)
inetd_services = check_services(["/etc/inetd.conf"], rpc_services)

found_services.extend(xinetd_services)
found_services.extend(inetd_services)

# Log results based on found services
with open(log_file_name, 'a') as f:
    if found_services:
        f.write(warn(f"불필요한 RPC 서비스가 활성화 되어 있습니다: {', '.join(found_services)}\n"))
    else:
        f.write(ok("불필요한 RPC 서비스가 비활성화 되어 있는 경우\n"))

bar()

# Print results
with open(log_file_name, 'r') as f:
    print(f.read())
print()
