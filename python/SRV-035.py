#!/usr/python3

import json
import os
import stat
import pwd
import subprocess

# JSON 데이터 구성
$jsonData = @{
    분류 = "시스템 보안"
    코드 = "SRV-035"
    위험도 = "중간"
    진단항목 = "취약한 서비스 활성화 상태"
    진단결과 = Check-VulnerableServices
    대응방안 = "취약한 서비스는 비활성화하십시오."
}

def BAR():
    print("=" * 40)

def log_message(message, file_path, mode='a'):
    with open(file_path, mode) as f:
        f.write(message + "\n")

# 결과 파일 초기화
tmp1 = "SCRIPTNAME.log"  # 'SCRIPTNAME'을 실제 스크립트 이름으로 바꿔주세요.
log_message("", tmp1, 'w')  # 로그 파일을 초기화합니다.

BAR()

code = "[SRV-035] 취약한 서비스 활성화"
description = "[양호]: 취약한 서비스가 비활성화된 경우\n[취약]: 취약한 서비스가 활성화된 경우\n"
log_message(f"{code}\n{description}", tmp1)

BAR()

# 취약한 서비스 리스트
services = ["echo", "discard", "daytime", "chargen"]
service_found = False

# /etc/xinetd.d 디렉터리에서 서비스 파일을 검사합니다.
for service in services:
    service_file = f"/etc/xinetd.d/{service}"
    try:
        with open(service_file, 'r') as file:
            if 'disable = yes' not in file.read():
                log_message(f"WARN: {service} 서비스가 /etc/xinetd.d 디렉터리 내 서비스 파일에서 실행 중입니다.", tmp1)
                service_found = True
                break
    except FileNotFoundError:
        continue

# /etc/inetd.conf 파일에서 서비스를 검사합니다.
if not service_found:
    try:
        with open("/etc/inetd.conf", 'r') as file:
            inetd_conf_content = file.readlines()
            for service in services:
                if any(service in line for line in inetd_conf_content if not line.strip().startswith("#")):
                    log_message(f"WARN: {service} 서비스가 /etc/inetd.conf 파일에서 실행 중입니다.", tmp1)
                    service_found = True
                    break
    except FileNotFoundError:
        pass

if not service_found:
    log_message("OK: ※ U-23 결과 : 양호(Good)", tmp1)

BAR()

# 최종 결과를 출력합니다.
with open(tmp1, 'r') as f:
    print(f.read())
print()
