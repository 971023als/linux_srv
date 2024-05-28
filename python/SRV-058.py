import re
import subprocess

def BAR():
    print("=" * 40)

def check_script_mapping(config_file, patterns):
    try:
        with open(config_file, 'r') as file:
            content = file.read()
            for pattern in patterns:
                if re.search(pattern, content):
                    return f"WARN: {config_file}에서 불필요한 스크립트 매핑이 발견됨"
            return f"OK: {config_file}에서 불필요한 스크립트 매핑이 발견되지 않음"
    except FileNotFoundError:
        return f"INFO: {config_file} 파일이 존재하지 않습니다."

BAR()

code = "[SRV-058] 웹 서비스의 불필요한 스크립트 매핑 존재"
description = "[양호]: 웹 서비스에서 불필요한 스크립트 매핑이 존재하지 않는 경우\n[취약]: 웹 서비스에서 불필요한 스크립트 매핑이 존재하는 경우"
print(f"{code}\n{description}\n")

BAR()

# Apache에서 스크립트 매핑 설정 확인
apache_config_file = "/etc/apache2/apache2.conf"
apache_patterns = ["AddHandler", "AddType"]
apache_result = check_script_mapping(apache_config_file, apache_patterns)
print(apache_result)

# Nginx에서 스크립트 매핑 설정 확인
nginx_config_file = "/etc/nginx/nginx.conf"
nginx_patterns = [r"location ~ \.php$"]
nginx_result = check_script_mapping(nginx_config_file, nginx_patterns)
print(nginx_result)

BAR()
