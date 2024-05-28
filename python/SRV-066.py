import subprocess
import re

def check_dns_zone_transfer(config_file):
    try:
        with open(config_file, 'r') as file:
            content = file.read()
            # Zone Transfer 설정 확인
            if re.search(r"allow-transfer\s*{\s*any\s*;}", content, re.IGNORECASE):
                return False  # 취약: Zone Transfer가 적절하게 제한되지 않음
        return True  # 양호: Zone Transfer가 안전하게 제한됨
    except FileNotFoundError:
        return None  # 파일이 존재하지 않음

# 결과 로깅 함수
def log_result(message, file_path):
    with open(file_path, "a") as file:
        file.write(message + "\n")

# 로그 파일 초기화
log_file = "dns_zone_transfer_check.log"
open(log_file, "w").close()

# DNS Zone Transfer 검사 및 결과 로깅
dns_config_file = "/etc/named.conf"
zone_transfer_check_result = check_dns_zone_transfer(dns_config_file)
if zone_transfer_check_result is True:
    log_result("OK: DNS Zone Transfer가 안전하게 제한되어 있는 경우", log_file)
elif zone_transfer_check_result is False:
    log_result("WARN: DNS Zone Transfer가 적절하게 제한되지 않은 경우", log_file)
else:
    log_result("INFO: /etc/named.conf 파일이 존재하지 않습니다.", log_file)

# 로그 파일 출력
with open(log_file, "r") as file:
    print(file.read())
