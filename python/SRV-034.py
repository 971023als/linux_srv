#!/usr/python3

import json
import os
import stat
import pwd
import subprocess

# JSON 데이터 구성
$jsonData = @{
    분류 = "시스템 보안"
    코드 = "SRV-034"
    위험도 = "중간"
    진단항목 = "불필요한 서비스 활성화 상태"
    진단결과 = Check-UnnecessaryServices
    대응방안 = "불필요한 서비스는 비활성화하십시오."
}

def BAR():
    print("=" * 40)

def log_message(message, file_path, mode='a'):
    with open(file_path, mode) as f:
        f.write(message + "\n")

def check_service_disabled(service_file, service_name):
    with open(service_file, 'r') as file:
        contents = file.read()
        if 'disable = yes' in contents:
            return True
        else:
            return False

# 결과 파일 초기화
tmp1 = "SCRIPTNAME.log"  # 'SCRIPTNAME'을 실제 스크립트 이름으로 바꿔주세요.
log_message("", tmp1, 'w')  # 로그 파일을 초기화합니다.

BAR()

code = "[SRV-034] 불필요한 서비스 활성화"
description = "[양호]: 불필요한 서비스가 비활성화된 경우\n[취약]: 불필요한 서비스가 활성화된 경우\n"
log_message(f"{code}\n{description}", tmp1)

BAR()

# 불필요한 서비스 리스트
r_command = ["rsh", "rlogin", "rexec", "shell", "login", "exec"]
services_checked = False

if os.path.isdir("/etc/xinetd.d"):
    for service in r_command:
        service_file = f"/etc/xinetd.d/{service}"
        if os.path.isfile(service_file):
            if not check_service_disabled(service_file, service):
                log_message(f"WARN: 불필요한 {service} 서비스가 실행 중입니다.", tmp1)
                services_checked = True
                break

if not services_checked and os.path.isfile("/etc/inetd.conf"):
    with open("/etc/inetd.conf", 'r') as file:
        inetd_conf_content = file.readlines()
        for service in r_command:
            for line in inetd_conf_content:
                if service in line and not line.strip().startswith("#"):
                    log_message(f"WARN: 불필요한 {service} 서비스가 실행 중입니다.", tmp1)
                    services_checked = True
                    break
            if services_checked:
                break

if not services_checked:
    log_message("OK: ※ U-21 결과 : 양호(Good)", tmp1)

BAR()

# 최종 결과를 출력합니다.
with open(tmp1, 'r') as f:
    print(f.read())
print()
