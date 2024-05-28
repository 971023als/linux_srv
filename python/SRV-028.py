#!/usr/python3

import json
import os
import stat
import pwd
import subprocess


# JSON 데이터 구성
$jsonData = @{
    분류 = "시스템 보안"
    코드 = "SRV-028"
    위험도 = "중간"
    진단항목 = "SSH 원격 터미널 접속 타임아웃 설정"
    진단결과 = "(변수: 양호, 취약)"
    현황 = (Get-SSHTimeoutStatus)
    대응방안 = "SSH 원격 터미널 접속 타임아웃을 적절하게 설정하십시오."
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

code = "[SRV-028] 원격 터미널 접속 타임아웃 미설정"
description = "[양호]: SSH 원격 터미널 접속 타임아웃이 적절하게 설정된 경우\n[취약]: SSH 원격 터미널 접속 타임아웃이 설정되지 않은 경우\n"
log_message(f"{code}\n{description}", tmp1)

BAR()

# SSH 설정 파일을 확인합니다.
SSH_CONFIG_FILE = "/etc/ssh/sshd_config"

# ClientAliveInterval과 ClientAliveCountMax를 확인합니다.
try:
    with open(SSH_CONFIG_FILE, 'r') as file:
        config_lines = file.readlines()
        client_alive_interval_set = any("ClientAliveInterval" in line for line in config_lines)
        client_alive_count_max_set = any("ClientAliveCountMax" in line for line in config_lines)
        
        if client_alive_interval_set and client_alive_count_max_set:
            result = "OK: SSH 원격 터미널 타임아웃 설정이 적절하게 구성되어 있습니다."
        else:
            result = "WARN: SSH 원격 터미널 타임아웃 설정이 미비합니다."
except FileNotFoundError:
    result = "ERROR: SSH 설정 파일(/etc/ssh/sshd_config)을 찾을 수 없습니다."

log_message(result, tmp1)

BAR()

# 최종 결과를 출력합니다.
with open(tmp1, 'r') as f:
    print(f.read())
