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



밑에 있는 코드를 위에 형태로 처럼 만들어줘

#!/usr/python3

import json
import os
import stat
import pwd
import subprocess
def BAR():
    print("=" * 40)

def log_message(message, file_path, mode='a'):
    with open(file_path, mode) as f:
        f.write(message + "\n")

# 결과 파일 초기화
tmp1 = "SCRIPTNAME.log"  # 'SCRIPTNAME'을 실제 스크립트 이름으로 바꿔주세요.
log_message("", tmp1, 'w')  # 로그 파일을 초기화합니다.

BAR()

code = "[SRV-040] 웹 서비스 디렉터리 리스팅 방지 설정 미흡"
description = "[양호]: 웹 서비스 디렉터리 리스팅이 적절하게 방지된 경우\n[취약]: 웹 서비스 디렉터리 리스팅 방지 설정이 미흡한 경우\n"
log_message(f"{code}\n{description}", tmp1)

BAR()

webconf_files = [".htaccess", "httpd.conf", "apache2.conf", "userdir.conf"]
warnings_found = False

for conf_file in webconf_files:
    find_command = f"find / -name {conf_file} -type f 2>/dev/null"
    find_results = subprocess.getoutput(find_command).split('\n')
    
    for result_path in find_results:
        if not result_path.strip():
            continue

        with open(result_path, 'r') as file:
            content = file.read()
            if "userdir.conf" in result_path:
                if "userdir disabled" not in content.lower():
                    if "options" in content.lower() and "-indexes" not in content.lower() and "indexes" in content.lower():
                        log_message(f"WARN: Apache 설정 파일에 디렉터리 검색 기능을 사용하도록 설정되어 있습니다. ({result_path})", tmp1)
                        warnings_found = True
                        break
            else:
                if "options" in content.lower() and "-indexes" not in content.lower() and "indexes" in content.lower():
                    log_message(f"WARN: Apache 설정 파일에 디렉터리 검색 기능을 사용하도록 설정되어 있습니다. ({result_path})", tmp1)
                    warnings_found = True
                    break

if not warnings_found:
    log_message("OK: ※ 양호(Good)", tmp1)

BAR()

# 최종 결과를 출력합니다.
with open(tmp1, 'r') as f:
    print(f.read())

