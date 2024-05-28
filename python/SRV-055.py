import os
import stat

def BAR():
    print("=" * 40)

def log_message(message, file_path, mode='a'):
    with open(file_path, mode) as f:
        f.write(message + "\n")

# 결과 파일 초기화
tmp1 = "SCRIPTNAME.log"  # 'SCRIPTNAME'을 실제 스크립트 이름으로 바꿔주세요.
log_message("", tmp1, 'w')  # 로그 파일을 초기화합니다.

BAR()

code = "[SRV-055] 웹 서비스 설정 파일 노출"
description = "[양호]: 웹 서비스 설정 파일이 외부에서 접근 불가능한 경우\n[취약]: 웹 서비스 설정 파일이 외부에서 접근 가능한 경우\n"
log_message(f"{code}\n{description}", tmp1)

BAR()

# 웹 서비스 설정 파일의 예시 경로
apache_config = "/etc/apache2/apache2.conf"
nginx_config = "/etc/nginx/nginx.conf"

# Apache 설정 파일의 접근 권한 확인
if os.path.isfile(apache_config):
    apache_config_permissions = os.stat(apache_config).st_mode
    if apache_config_permissions & stat.S_IRWXU == stat.S_IRUSR:
        log_message(f"OK: Apache 설정 파일({apache_config})이 외부 접근으로부터 보호됩니다.", tmp1)
    else:
        log_message(f"WARN: Apache 설정 파일({apache_config})의 접근 권한이 취약합니다.", tmp1)
else:
    log_message(f"INFO: Apache 설정 파일({apache_config})이 존재하지 않습니다.", tmp1)

# Nginx 설정 파일의 접근 권한 확인
if os.path.isfile(nginx_config):
    nginx_config_permissions = os.stat(nginx_config).st_mode
    if nginx_config_permissions & stat.S_IRWXU == stat.S_IRUSR:
        log_message(f"OK: Nginx 설정 파일({nginx_config})이 외부 접근으로부터 보호됩니다.", tmp1)
    else:
        log_message(f"WARN: Nginx 설정 파일({nginx_config})의 접근 권한이 취약합니다.", tmp1)
else:
    log_message(f"INFO: Nginx 설정 파일({nginx_config})이 존재하지 않습니다.", tmp1)

BAR()

# 최종 결과를 출력합니다.
with open(tmp1, 'r') as f:
    print(f.read())
print()
