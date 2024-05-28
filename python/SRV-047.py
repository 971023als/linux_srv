import os
import re
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

code = "[SRV-047] 웹 서비스 경로 내 불필요한 링크 파일 존재"
description = "[양호]: 웹 서비스 경로 내 불필요한 심볼릭 링크 파일이 존재하지 않는 경우\n[취약]: 웹 서비스 경로 내 불필요한 심볼릭 링크 파일이 존재하는 경우\n"
log_message(f"{code}\n{description}", tmp1)

BAR()

webconf_files = [".htaccess", "httpd.conf", "apache2.conf", "userdir.conf"]
warnings_found = False

for conf_file in webconf_files:
    find_results = subprocess.getoutput(f"find / -name {conf_file} -type f 2>/dev/null").split('\n')
    
    for result_path in find_results:
        if not result_path.strip():
            continue

        with open(result_path, 'r') as file:
            content = file.read()
            if re.search(r'Options.*FollowSymLinks', content) and not re.search(r'Options.*-FollowSymLinks', content):
                log_message(f"WARN: Apache 설정 파일에 심볼릭 링크 사용을 제한하도록 설정하지 않습니다. ({result_path})", tmp1)
                warnings_found = True
                break

if not warnings_found:
    log_message("OK: ※ U-39 결과 : 양호(Good)", tmp1)

BAR()

# 최종 결과를 출력합니다.
with open(tmp1, 'r') as f:
    print(f.read())
print()
