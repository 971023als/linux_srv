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

code = "[SRV-042] 웹 서비스 상위 디렉터리 접근 제한 설정 미흡"
description = "[양호]: DocumentRoot가 별도의 보안 디렉터리로 지정된 경우\n[취약]: DocumentRoot가 기본 디렉터리 또는 민감한 디렉터리로 지정된 경우\n"
log_message(f"{code}\n{description}", tmp1)

BAR()

webconf_files = [".htaccess", "httpd.conf", "apache2.conf", "userdir.conf"]
file_exists_count = 0
warnings_found = False

for conf_file in webconf_files:
    find_command = f"find / -name {conf_file} -type f"
    find_results = subprocess.getoutput(find_command).split('\n')
    
    for result_path in find_results:
        if not result_path.strip():
            continue

        file_exists_count += 1
        with open(result_path, 'r') as file:
            content = file.read()
            allow_override = "AllowOverride" in content
            allow_override_none = "AllowOverride None" in content
            if allow_override and not allow_override_none:
                log_message(f"WARN: 웹 서비스 상위 디렉터리에 이동 제한을 설정하지 않았습니다. ({result_path})", tmp1)
                warnings_found = True
                break

if not warnings_found:
    if file_exists_count == 0:
        ps_apache_count = subprocess.getoutput("ps -ef | grep -iE 'httpd|apache2' | grep -v 'grep' | wc -l")
        if int(ps_apache_count) > 0:
            log_message("WARN: Apache 서비스를 사용하고, 웹 서비스 상위 디렉터리에 이동 제한을 설정하는 파일이 없습니다.", tmp1)
        else:
            log_message("OK: ※ U-37 결과 : 양호(Good)", tmp1)
    else:
        log_message("OK: ※ U-37 결과 : 양호(Good)", tmp1)

BAR()

# 최종 결과를 출력합니다.
with open(tmp1, 'r') as f:
    print(f.read())
print()
