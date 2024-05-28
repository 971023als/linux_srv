#!/usr/python3

import json
import os
import stat
import pwd
import subprocess

# Python dictionary for JSON data
jsonData = {
    "분류": "시스템 보안",
    "코드": "SRV-023",
    "위험도": "중간",
    "진단항목": "SSH 서비스 암호화 수준 설정",
    "현황": "Placeholder for Get-SSHSecurityStatus function",
    "대응방안": "SSH 서비스의 암호화 수준을 강화하세요."
}

def bar():
    print("=" * 40)

def log_message(message, file_path):
    with open(file_path, 'a') as file:
        file.write(message + "\n")

# Define the log file path
log_file_name = "ssh_security_audit.log"

# Clear or create the log file
with open(log_file_name, 'w') as file:
    pass

bar()

code = "[SRV-023] 원격 터미널 서비스의 암호화 수준 설정 미흡"
log_message(code, log_file_name)
log_message("[양호]: SSH 서비스의 암호화 수준이 적절하게 설정된 경우", log_file_name)
log_message("[취약]: SSH 서비스의 암호화 수준 설정이 미흡한 경우", log_file_name)

bar()

# SSH configuration file path
ssh_config_file = "/etc/ssh/sshd_config"

# SSH encryption related settings to check
encryption_settings = ["KexAlgorithms", "Ciphers", "MACs"]

# Check SSH configuration for encryption settings
for setting in encryption_settings:
    try:
        # Use grep to check for the presence of each setting
        subprocess.check_output(['grep', f'^{setting}', ssh_config_file], stderr=subprocess.STDOUT)
        log_message(f"OK: {ssh_config_file} 파일에서 {setting} 설정이 적절하게 구성되어 있습니다.", log_file_name)
    except subprocess.CalledProcessError:
        log_message(f"WARN: {ssh_config_file} 파일에서 {setting} 설정이 미흡합니다.", log_file_name)

bar()

# Print results
with open(log_file_name, 'r') as file:
    print(file.read())