def check_dns_dynamic_updates(dns_config_path="/etc/bind/named.conf"):
    try:
        with open(dns_config_path, 'r') as dns_config_file:
            dns_config_contents = dns_config_file.read()
            
            # 동적 업데이트 설정 확인
            if "allow-update" in dns_config_contents:
                dynamic_updates = [line.strip() for line in dns_config_contents.split('\n') if "allow-update" in line]
                print("WARN: DNS 동적 업데이트 설정이 취약합니다:", dynamic_updates)
            else:
                print("OK: DNS 동적 업데이트가 안전하게 구성되어 있습니다.")
                
    except FileNotFoundError:
        print("INFO: DNS 설정 파일이 존재하지 않습니다.")

if __name__ == "__main__":
    check_dns_dynamic_updates()
