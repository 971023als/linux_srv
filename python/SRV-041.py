#!/usr/python3

import json
import os
import stat
import pwd
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

code = "[SRV-041] 웹 서비스의 CGI 스크립트 관리 미흡"
description = "[양호]: CGI 스크립트 관리가 적절하게 설정된 경우\n[취약]: CGI 스크립트 관리가 미흡한 경우\n"
log_message(f"{code}\n{description}", tmp1)

BAR()

# Apache 설정 파일 확인
APACHE_CONFIG_FILE = "/etc/apache2/apache2.conf"

# CGI 스크립트 실행 및 관리 설정 확인
try:
    with open(APACHE_CONFIG_FILE, 'r') as file:
        config_content = file.read()
        cgi_exec_option = re.findall(r"^\s*Options.*ExecCGI", config_content, re.MULTILINE)
        cgi_handler_directive = re.findall(r"(AddHandler cgi-script|ScriptAlias)", config_content)

    if cgi_exec_option or cgi_handler_directive:
        result = f"WARN: Apache에서 CGI 스크립트 실행이 허용되어 있습니다: {cgi_exec_option}, {cgi_handler_directive}"
    else:
        result = "OK: Apache에서 CGI 스크립트 실행이 적절하게 제한되어 있습니다."
except FileNotFoundError:
    result = f"ERROR: Apache 설정 파일({APACHE_CONFIG_FILE})을 찾을 수 없습니다."

log_message(result, tmp1)

BAR()

# 최종 결과를 출력합니다.
with open(tmp1, 'r') as f:
    print(f.read())
print()
