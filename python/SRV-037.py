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

code = "[SRV-037] 취약한 FTP 서비스 실행"
description = "[양호]: FTP 서비스가 비활성화 되어 있는 경우\n[취약]: FTP 서비스가 활성화 되어 있는 경우\n"
log_message(f"{code}\n{description}", tmp1)

BAR()

# FTP 서비스의 활성화 여부를 확인합니다.
def check_ftp_service():
    # netstat를 사용하여 FTP 포트(기본값 21)의 상태를 확인합니다.
    netstat_output = subprocess.getoutput("netstat -nat")
    # /etc/services에서 FTP 포트를 찾아 확인합니다.
    with open('/etc/services', 'r') as services_file:
        services_content = services_file.read()
        ftp_ports = re.findall(r'^ftp\s+(\d+)/tcp', services_content, re.MULTILINE)
        for port in ftp_ports:
            if f":{port} " in netstat_output:
                return "WARN: ftp 서비스가 실행 중입니다."

    # 프로세스 목록에서 FTP 관련 서비스를 찾습니다.
    ps_output = subprocess.getoutput("ps -ef | grep -iE 'ftp|vsftpd|proftp' | grep -v 'grep'")
    if ps_output:
        return "WARN: ftp 서비스가 실행 중입니다."

    return "OK: ※ U-61 결과 : 양호(Good)"

result = check_ftp_service()
log_message(result, tmp1)

BAR()

# 최종 결과를 출력합니다.
with open(tmp1, 'r') as f:
    print(f.read())
