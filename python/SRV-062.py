import re

def BAR():
    print("=" * 40)

def check_dns_config(config_file):
    try:
        with open(config_file, 'r') as file:
            content = file.read()
            # 버전 정보 숨김 옵션 확인
            if re.search(r"version\s+\"none\"", content):
                print("OK: DNS 서비스에서 버전 정보가 숨겨져 있습니다.")
            else:
                print("WARN: DNS 서비스에서 버전 정보가 노출될 수 있습니다.")
            
            # 불필요한 전송 허용 확인
            if re.search(r"allow-transfer", content):
                print("WARN: DNS 서비스에서 불필요한 Zone Transfer가 허용될 수 있습니다.")
            else:
                print("OK: DNS 서비스에서 불필요한 Zone Transfer가 제한됩니다.")
    except FileNotFoundError:
        print(f"INFO: DNS 설정 파일({config_file})이 존재하지 않습니다.")

BAR()

code = "[SRV-062] DNS 서비스 정보 노출"
description = "[양호]: DNS 서비스 정보가 안전하게 보호되고 있는 경우\n[취약]: DNS 서비스 정보가 노출되고 있는 경우"
print(f"{code}\n{description}\n")

BAR()

# DNS 설정 파일 경로
dns_config_file = "/etc/bind/named.conf"  # BIND 사용 예시, 실제 환경에 따라 달라질 수 있음

check_dns_config(dns_config_file)

BAR()
