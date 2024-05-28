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

code = "[SRV-043] 웹 서비스 경로 내 불필요한 파일 존재"
description = "[양호]: 웹 서비스 경로에 불필요한 파일이 존재하지 않는 경우\n[취약]: 웹 서비스 경로에 불필요한 파일이 존재하는 경우\n"
log_message(f"{code}\n{description}", tmp1)

BAR()

webconf_files = [".htaccess", "httpd.conf", "apache2.conf"]
file_exists_count = 0
warnings_found = False

for conf_file in webconf_files:
    find_results = subprocess.getoutput(f"find / -name {conf_file} -type f 2>/dev/null").split('\n')
    
    for result_path in find_results:
        if not result_path.strip():
            continue

        file_exists_count += 1
        with open(result_path, 'r') as file:
            content = file.read()
            documentroot_matches = re.findall(r'DocumentRoot\s+"([^"]+)"', content, re.IGNORECASE)
            for documentroot in documentroot_matches:
                if documentroot in ['/usr/local/apache/htdocs', '/usr/local/apache2/htdocs', '/var/www/html']:
                    log_message(f"WARN: Apache DocumentRoot를 기본 디렉터리로 설정했습니다. ({result_path})", tmp1)
                    warnings_found = True
                    break
                else:
                    continue

if file_exists_count == 0:
    ps_apache_count = subprocess.getoutput("ps -ef | grep -iE 'httpd|apache2' | grep -v 'grep' | wc -l")
    if int(ps_apache_count) > 0:
        log_message("WARN: Apache 서비스를 사용하고, DocumentRoot를 설정하는 파일이 없습니다.", tmp1)
    else:
        log_message("OK: 양호(Good)", tmp1)
elif not warnings_found:
    log_message("OK: 양호(Good)", tmp1)

BAR()

# 최종 결과를 출력합니다.
with open(tmp1, 'r') as f:
    print(f.read())
print()
