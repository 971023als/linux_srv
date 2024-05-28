#!/usr/python3

import json
import os
import stat
import pwd
import subprocess

# JSON 데이터 구성
$jsonData = @{
    분류 = "시스템 보안"
    코드 = "SRV-031"
    위험도 = "중간"
    진단항목 = "SMB 서비스 계정 목록 및 네트워크 공유 이름 노출"
    진단결과 = "(변수: 양호, 취약)"
    현황 = (Get-SMBExposureStatus)
    대응방안 = "SMB 서비스의 네트워크 공유 열거를 제한하도록 설정하십시오."
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

code = "[SRV-031] 계정 목록 및 네트워크 공유 이름 노출"
description = "[양호]: SMB 서비스에서 계정 목록 및 네트워크 공유 이름이 노출되지 않는 경우\n[취약]: SMB 서비스에서 계정 목록 및 네트워크 공유 이름이 노출되는 경우\n"
log_message(f"{code}\n{description}", tmp1)

BAR()

# SMB 설정 파일을 확인합니다.
SMB_CONF_FILE = "/etc/samba/smb.conf"

# 공유 목록 및 계정 정보 노출을 방지하는 설정을 확인합니다.
try:
    with open(SMB_CONF_FILE, 'r') as file:
        smb_conf_content = file.read()
        # 예: 'enum shares', 'enum users' 설정을 확인
        if "enum shares" in smb_conf_content or "enum users" in smb_conf_content:
            result = "WARN: SMB 서비스에서 계정 목록 또는 네트워크 공유 이름이 노출될 수 있습니다."
        else:
            result = "OK: SMB 서비스에서 계정 목록 및 네트워크 공유 이름이 적절하게 보호되고 있습니다."
except FileNotFoundError:
    result = "ERROR: SMB 설정 파일(/etc/samba/smb.conf)을 찾을 수 없습니다."

log_message(result, tmp1)

BAR()

# 최종 결과를 출력합니다.
with open(tmp1, 'r') as f:
    print(f.read())
print()
