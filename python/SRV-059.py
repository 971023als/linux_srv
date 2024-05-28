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

code = "[SRV-059] 웹 서비스 서버 명령 실행 기능 제한 설정 미흡"
description = "[양호]: 웹 서비스에서 서버 명령 실행 기능이 적절하게 제한된 경우\n[취약]: 웹 서비스에서 서버 명령 실행 기능의 제한이 미흡한 경우"
print(f"{code}\n{description}\n")

BAR()

# Apache 설정 파일의 경로
apache_config_file = "/etc/apache2/apache2.conf"

# Apache에서 서버 명령 실행 제한 확인
try:
    with open(apache_config_file, 'r') as file:
        content = file.read()
        if re.search(r"^\s*ScriptAlias", content, re.MULTILINE):
            print(f"WARN: Apache에서 서버 명령 실행이 허용될 수 있습니다: {apache_config_file}")
        else:
            print(f"OK: Apache에서 서버 명령 실행 기능이 적절하게 제한됩니다: {apache_config_file}")
except FileNotFoundError:
    print(f"INFO: Apache 설정 파일({apache_config_file})이 존재하지 않습니다.")

# Nginx 설정 파일의 경로
nginx_config_file = "/etc/nginx/nginx.conf"

# Nginx에서 FastCGI 스크립트 실행 제한 확인
try:
    with open(nginx_config_file, 'r') as file:
        content = file.read()
        if re.search(r"fastcgi_pass", content):
            print(f"WARN: Nginx에서 FastCGI를 통한 서버 명령 실행이 허용될 수 있습니다: {nginx_config_file}")
        else:
            print(f"OK: Nginx에서 FastCGI를 통한 서버 명령 실행 기능이 적절하게 제한됩니다: {nginx_config_file}")
except FileNotFoundError:
    print(f"INFO: Nginx 설정 파일({nginx_config_file})이 존재하지 않습니다.")

BAR()
