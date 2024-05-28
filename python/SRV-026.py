#!/usr/python3

import json
import os
import stat
import pwd
import subprocess

# JSON 데이터 구성
$jsonData = @{
    분류 = "시스템 보안"
    코드 = "SRV-026"
    위험도 = "중간"
    진단항목 = "SSH 서비스의 root 계정 원격 접속 제한"
    진단결과 = "(변수: 양호, 취약)"
    현황 = (Get-SSHRootLoginStatus)
    대응방안 = "SSH를 통한 Administrator 계정의 원격 접속을 'no'로 제한하십시오."
}


def BAR():
    print("=" * 40)

def WARN(message):
    return f"WARNING: {message}\n"

def OK(message):
    return f"OK: {message}\n"

def check_ssh_root_login():
    sshd_config_files = subprocess.getoutput("find / -name sshd_config 2>/dev/null").split()
    for sshd_config in sshd_config_files:
        try:
            with open(sshd_config, 'r') as file:
                for line in file:
                    if line.strip().startswith("PermitRootLogin"):
                        if "no" in line.strip().split():
                            return OK("SSH를 통한 root 계정의 원격 접속이 제한됩니다.")
                        else:
                            return WARN("SSH 서비스를 사용하고, sshd_config 파일에서 root 계정의 원격 접속이 허용되어 있습니다.")
        except FileNotFoundError:
            continue
    return WARN("ssh 서비스를 사용하고, sshd_config 파일이 없거나 root 계정의 원격 접속 제한 설정을 찾을 수 없습니다.")

# 결과 파일 초기화
tmp1 = "SCRIPTNAME.log"  # 'SCRIPTNAME'을 실제 스크립트 이름으로 바꿔주세요.
with open(tmp1, 'w') as f:
    pass

BAR()

code = "[SRV-026] root 계정 원격 접속 제한 미비"
log_message = f"{code}\n[양호]: SSH를 통한 root 계정의 원격 접속이 제한된 경우\n[취약]: SSH를 통한 root 계정의 원격 접속이 제한되지 않은 경우\n"
with open(tmp1, 'a') as f:
    f.write(log_message)

BAR()

result = check_ssh_root_login()
with open(tmp1, 'a') as f:
    f.write(result)

BAR()

# 최종 결과를 출력합니다.
with open(tmp1, 'r') as f:
    print(f.read())
print()
