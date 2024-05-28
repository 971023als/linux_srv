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

code = "[SRV-046] 웹 서비스 경로 설정 미흡"
description = "[양호]: 웹 서비스의 경로 설정이 안전하게 구성된 경우\n[취약]: 웹 서비스의 경로 설정이 취약하게 구성된 경우\n"
log_message(f"{code}\n{description}", tmp1)

BAR()

# Apache 설정 확인
APACHE_CONFIG_FILE = "/etc/apache2/apache2.conf"
NGINX_CONFIG_FILE = "/etc/nginx/nginx.conf"

# Apache 설정 확인
try:
    with open(APACHE_CONFIG_FILE, 'r') as file:
        content = file.read()
        if re.search(r"^\s*<Directory", content, re.MULTILINE) and re.search(r"Options -Indexes", content, re.MULTILINE):
            log_message("OK: Apache 설정에서 적절한 경로 설정이 확인됨: " + APACHE_CONFIG_FILE, tmp1)
        else:
            log_message("WARN: Apache 설정에서 취약한 경로 설정이 확인됨: " + APACHE_CONFIG_FILE, tmp1)
except FileNotFoundError:
    log_message("INFO: Apache 설정 파일이 존재하지 않습니다: " + APACHE_CONFIG_FILE, tmp1)

# Nginx 설정 확인
try:
    with open(NGINX_CONFIG_FILE, 'r') as file:
        content = file.read()
        if re.search(r"^\s*location", content, re.MULTILINE):
            log_message("OK: Nginx 설정에서 적절한 경로 설정이 확인됨: " + NGINX_CONFIG_FILE, tmp1)
        else:
            log_message("WARN: Nginx 설정에서 취약한 경로 설정이 확인됨: " + NGINX_CONFIG_FILE, tmp1)
except FileNotFoundError:
    log_message("INFO: Nginx 설정 파일이 존재하지 않습니다: " + NGINX_CONFIG_FILE, tmp1)

BAR()

# 최종 결과를 출력합니다.
with open(tmp1, 'r') as f:
    print(f.read())
print()
