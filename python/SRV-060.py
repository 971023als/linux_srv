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

code = "[SRV-060] 웹 서비스 기본 계정(아이디 또는 비밀번호) 미변경"
description = "[양호]: 웹 서비스의 기본 계정(아이디 또는 비밀번호)이 변경된 경우\n[취약]: 웹 서비스의 기본 계정(아이디 또는 비밀번호)이 변경되지 않은 경우"
print(f"{code}\n{description}\n")

BAR()

# 웹 서비스의 기본 계정 설정 파일 예시 (실제 환경에 맞게 조정)
config_file = "/etc/web_service/config"

try:
    with open(config_file, 'r') as file:
        content = file.read()
        # 기본 계정 설정 확인 (예시: 'admin' 또는 'password')
        if re.search(r"username=admin|password=password", content):
            log_message(f"WARN: 웹 서비스의 기본 계정(아이디 또는 비밀번호)이 변경되지 않았습니다: {config_file}", tmp1)
        else:
            log_message(f"OK: 웹 서비스의 기본 계정(아이디 또는 비밀번호)이 변경되었습니다: {config_file}", tmp1)
except FileNotFoundError:
    log_message(f"INFO: 웹 서비스의 기본 계정 설정 파일({config_file})이 존재하지 않습니다.", tmp1)

BAR()

# 최종 결과를 출력합니다.
with open(tmp1, 'r') as f:
    print(f.read())
print()
