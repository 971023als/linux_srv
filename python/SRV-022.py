#!/usr/python3

import json
import os
import stat
import pwd
import subprocess

# Python dictionary for JSON data
jsonData = {
    "분류": "시스템 보안",
    "코드": "SRV-022",
    "위험도": "중간",
    "진단항목": "계정의 비밀번호 미설정, 빈 암호 사용 관리 미흡",
    "진단결과": "(변수: 양호, 취약)",
    "현황": "Placeholder for Check-AccountPasswordSettings function",
    "대응방안": "모든 계정에 강력한 비밀번호를 설정하고 빈 비밀번호 사용을 금지하세요."
}

def bar():
    print("=" * 40)

def log_message(message, file_path):
    with open(file_path, 'a') as f:
        f.write(message + "\n")

# Define the log file path
log_file_name = "password_audit.log"

# Clear or create the log file
with open(log_file_name, 'w') as f:
    pass

bar()

code = "[SRV-022] 계정의 비밀번호 미설정, 빈 암호 사용 관리 미흡"
log_message(code, log_file_name)
log_message("[양호]: 모든 계정에 비밀번호가 설정되어 있고 빈 비밀번호를 사용하는 계정이 없는 경우", log_file_name)
log_message("[취약]: 비밀번호가 설정되지 않거나 빈 비밀번호를 사용하는 계정이 있는 경우", log_file_name)

bar()

# Check for empty passwords in /etc/shadow
empty_passwords = 0
if os.path.exists("/etc/shadow"):
    with open("/etc/shadow", 'r') as shadow_file:
        for line in shadow_file:
            user, enc_passwd, *_ = line.split(":")
            if enc_passwd in ("", "!", "*"):
                message_type = "WARN" if enc_passwd == "" else "OK"
                message = f"{message_type} 비밀번호가 설정되지 않은 계정: {user}" if enc_passwd == "" else f"{message_type} 비밀번호가 잠긴 계정: {user}"
                log_message(message, log_file_name)
                if enc_passwd == "":
                    empty_passwords += 1
else:
    log_message("ERROR: /etc/shadow 파일을 찾을 수 없습니다.", log_file_name)

# Log final result based on the presence of empty passwords
result_message = "[결과] 취약: 비밀번호가 설정되지 않거나 빈 비밀번호를 사용하는 계정이 존재합니다." if empty_passwords > 0 else "[결과] 양호: 모든 계정에 비밀번호가 설정되어 있고 빈 비밀번호를 사용하는 계정이 없습니다."
log_message(result_message, log_file_name)

bar()

# Print results
with open(log_file_name, 'r') as f:
    print(f.read())
