#!/usr/python3

import json
import os
import stat
import pwd
import subprocess

# JSON 데이터 구성
$jsonData = @{
    분류 = "시스템 보안"
    코드 = "SRV-029"
    위험도 = "중간"
    진단항목 = "SMB 서비스 세션 중단 시간 설정"
    진단결과 = "(변수: 양호, 취약)"
    현황 = (Get-SMBSessionTimeoutStatus)
    대응방안 = "SMB 서비스의 세션 중단 시간을 적절하게 설정하십시오."
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

code = "[SRV-029] SMB 세션 중단 관리 설정 미비"
description = "[양호]: SMB 서비스의 세션 중단 시간이 적절하게 설정된 경우\n[취약]: SMB 서비스의 세션 중단 시간 설정이 미비한 경우\n"
log_message(f"{code}\n{description}", tmp1)

BAR()

# SMB 설정 파일을 확인합니다.
SMB_CONF_FILE = "/etc/samba/smb.conf"

# SMB 세션 중단 시간 설정을 확인합니다.
if os.path.isfile(SMB_CONF_FILE):
    with open(SMB_CONF_FILE, 'r') as file:
        lines = file.readlines()
        deadtime_line = [line for line in lines if line.strip().startswith("deadtime")]
        if deadtime_line:
            deadtime_value = deadtime_line[0].split('=')[1].strip()
            if int(deadtime_value) > 0:
                result = f"OK: SMB 세션 중단 시간(deadtime)이 적절하게 설정되어 있습니다: {deadtime_value} 분"
            else:
                result = "WARN: SMB 세션 중단 시간(deadtime) 설정이 미비합니다."
        else:
            result = f"WARN: SMB 세션 중단 시간(deadtime) 설정이 '{SMB_CONF_FILE}' 파일에 존재하지 않습니다."
else:
    result = f"ERROR: SMB 설정 파일({SMB_CONF_FILE})을 찾을 수 없습니다."

log_message(result, tmp1)

BAR()

# 최종 결과를 출력합니다.
with open(tmp1, 'r') as f:
    print(f.read())
print()
