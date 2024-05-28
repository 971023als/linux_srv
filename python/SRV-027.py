#!/usr/python3

import json
import os
import stat
import pwd
import subprocess

# JSON 데이터 구성
$jsonData = @{
    분류 = "시스템 보안"
    코드 = "SRV-027"
    위험도 = "중간"
    진단항목 = "서비스 접근 IP 및 포트 제한"
    진단결과 = "(변수: 양호, 취약)"
    현황 = (Get-FirewallStatus)
    대응방안 = "서비스 접근에 대한 IP 및 포트 제한을 설정하십시오."
}

def BAR():
    print("=" * 40)

def WARN(message):
    return f"WARNING: {message}\n"

def OK(message):
    return f"OK: {message}\n"

def check_access_control():
    hosts_deny_path = "/etc/hosts.deny"
    hosts_allow_path = "/etc/hosts.allow"

    if os.path.isfile(hosts_deny_path):
        with open(hosts_deny_path, 'r') as f:
            deny_contents = f.read().replace(' ', '')
            if 'ALL:ALL' in deny_contents.upper():
                if os.path.isfile(hosts_allow_path):
                    with open(hosts_allow_path, 'r') as f:
                        allow_contents = f.read().replace(' ', '')
                        if 'ALL:ALL' in allow_contents.upper():
                            return WARN("/etc/hosts.allow 파일에 'ALL : ALL' 설정이 있습니다.")
                        else:
                            return OK("※ U-18 결과 : 양호(Good)")
                else:
                    return OK("※ U-18 결과 : 양호(Good)")
            else:
                return WARN("/etc/hosts.deny 파일에 'ALL : ALL' 설정이 없습니다.")
    else:
        return WARN("/etc/hosts.deny 파일이 없습니다.")

# 결과 파일 초기화
tmp1 = "SCRIPTNAME.log"  # 'SCRIPTNAME'을 실제 스크립트 이름으로 바꿔주세요.
with open(tmp1, 'w') as f:
    pass

BAR()

code = "[SRV-027] 서비스 접근 IP 및 포트 제한 미비"
log_message = f"{code}\n[양호]: 서비스에 대한 IP 및 포트 접근 제한이 적절하게 설정된 경우\n[취약]: 서비스에 대한 IP 및 포트 접근 제한이 설정되지 않은 경우\n"
with open(tmp1, 'a') as f:
    f.write(log_message)

BAR()

result = check_access_control()
with open(tmp1, 'a') as f:
    f.write(result)

BAR()

# 최종 결과를 출력합니다.
with open(tmp1, 'r') as f:
    print(f.read())
print()
