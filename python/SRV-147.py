import subprocess

def check_snmp_service():
    try:
        # SNMP 서비스 프로세스를 찾습니다.
        result = subprocess.check_output("ps -ef | grep -i 'snmp' | grep -v 'grep'", shell=True, text=True)
        if result.strip():
            print("WARN: SNMP 서비스를 사용하고 있습니다.")
            print("활성화된 SNMP 서비스:")
            print(result)
        else:
            print("OK: SNMP 서비스가 비활성화되어 있습니다.")
    except subprocess.CalledProcessError as e:
        print(f"Error checking SNMP service: {e}")

if __name__ == "__main__":
    check_snmp_service()
