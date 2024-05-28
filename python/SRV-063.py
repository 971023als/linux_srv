import re

def BAR():
    print("=" * 40)

def check_dns_recursive_query(config_file):
    try:
        with open(config_file, 'r') as file:
            content = file.read()
            # 재귀 쿼리 설정 확인
            match = re.search(r"allow-recursion\s*{([^}]+)};", content)
            if match:
                recursion_setting = match.group(1).strip()
                if "localhost;" in recursion_setting or "localnets;" in recursion_setting:
                    print(f"OK: DNS 서버에서 재귀적 쿼리가 안전하게 제한됨: {recursion_setting}")
                else:
                    print(f"WARN: DNS 서버에서 재귀적 쿼리 제한이 미흡함: {recursion_setting}")
            else:
                print("OK: DNS 서버에서 재귀적 쿼리가 기본적으로 제한됨")
    except FileNotFoundError:
        print(f"INFO: DNS 설정 파일({config_file})이 존재하지 않습니다.")

BAR()

code = "[SRV-063] DNS Recursive Query 설정 미흡"
description = "[양호]: DNS 서버에서 재귀적 쿼리가 제한적으로 설정된 경우\n[취약]: DNS 서버에서 재귀적 쿼리가 적절하게 제한되지 않은 경우"
print(f"{code}\n{description}\n")

BAR()

# DNS 설정 파일 경로
dns_config_file = "/etc/bind/named.conf.options" # BIND 예시, 실제 파일 경로는 다를 수 있음

check_dns_recursive_query(dns_config_file)

BAR()
