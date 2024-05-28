import subprocess
import re

def BAR():
    print("=" * 40)

def log_message(message, file_path, mode='a'):
    with open(file_path, mode) as f:
        f.write(message + "\n")

# 결과 파일 초기화
tmp1 = "SCRIPTNAME.log"  # 'SCRIPTNAME'을 실제 스크립트 이름으로 바꿔주세요.
log_message("", tmp1, 'w')  # 로그 파일을 초기화합니다.

BAR()

code = "[SRV-048] 불필요한 웹 서비스 실행"
description = "[양호]: 불필요한 웹 서비스가 실행되지 않고 있는 경우\n[취약]: 불필요한 웹 서비스가 실행되고 있는 경우\n"
log_message(f"{code}\n{description}", tmp1)

BAR()

webconf_files = [".htaccess", "httpd.conf", "apache2.conf"]
serverroot_directories = []

for conf_file in webconf_files:
    find_command = f"find / -name {conf_file} -type f"
    find_results = subprocess.getoutput(find_command).split('\n')
    
    for result_path in find_results:
        if not result_path.strip():
            continue

        with open(result_path, 'r') as file:
            content = file.read()
            serverroot_matches = re.findall(r'ServerRoot\s+"([^"]+)"', content)
            serverroot_directories.extend(serverroot_matches)

apache_commands = ['apache2 -V', 'httpd -V']
for cmd in apache_commands:
    try:
        output = subprocess.check_output(cmd, shell=True, stderr=subprocess.STDOUT, text=True)
        serverroot_matches = re.findall(r'SERVER_CONFIG_FILE="([^"]+)"', output)
        serverroot_directories.extend(serverroot_matches)
    except subprocess.CalledProcessError:
        continue

warnings_found = False
for directory in serverroot_directories:
    find_manual_command = f"find {directory} -name 'manual' -type d"
    manual_directories = subprocess.getoutput(find_manual_command).split('\n')
    if manual_directories:
        warnings_found = True
        log_message(f"WARN: Apache 홈 디렉터리 내 기본으로 생성되는 불필요한 파일 및 디렉터리가 제거되어 있지 않습니다. 위치: {', '.join(manual_directories)}", tmp1)

if not warnings_found:
    log_message("OK: 결과 : 양호(Good)", tmp1)

BAR()

# 최종 결과를 출력합니다.
with open(tmp1, 'r') as f:
    print(f.read())
print()
