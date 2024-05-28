#!/usr/python3

import json
import os
import stat
import pwd
import subprocess

# Python dictionary for JSON data
jsonData = {
    "분류": "시스템 보안",
    "코드": "SRV-024",
    "위험도": "중간",
    "진단항목": "Telnet 서비스 보안 인증 방식 사용 여부",
    "진단결과": "(변수: 양호, 취약)",
    "현황": "Placeholder for Get-TelnetStatus function",
    "대응방안": "Telnet 서비스를 비활성화하거나 보안 인증 방식을 사용해야 합니다."
}

def bar():
    print("=" * 40)

def log_message(message, file_path):
    with open(file_path, 'a') as file:
        file.write(message + "\n")

# Define the log file path
log_file_name = "telnet_security_audit.log"

# Clear or create the log file
with open(log_file_name, 'w') as file:
    pass

bar()

# Log initial information
code = "[SRV-024] 취약한 Telnet 인증 방식 사용"
initial_message = f"{code}\n[양호]: Telnet 서비스가 비활성화되어 있거나 보안 인증 방식을 사용하는 경우\n[취약]: Telnet 서비스가 활성화되어 있고 보안 인증 방식을 사용하지 않는 경우\n"
log_message(initial_message, log_file_name)

bar()

# Check the status of Telnet service
try:
    # Using systemctl to check the active status of telnet.service (assuming telnet.socket is not in use)
    subprocess.check_output(["systemctl", "is-active", "--quiet", "telnet.service"])
    result = "WARNING: Telnet 서비스가 활성화되어 있습니다. 추가 보안 설정 확인이 필요할 수 있습니다.\n"
except subprocess.CalledProcessError:
    # Service is not active
    result = "OK: Telnet 서비스가 비활성화되어 있습니다.\n"

log_message(result, log_file_name)

bar()

# Print results
with open(log_file_name, 'r') as file:
    print(file.read())
