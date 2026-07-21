import subprocess

def check_dns_service_status(service_name="named"):
    try:
        # DNS 서비스 상태 확인
        result = subprocess.run(['systemctl', 'is-active', service_name], stdout=subprocess.PIPE, text=True)
        service_status = result.stdout.strip()
        
        if service_status == "active":
            print("WARN: DNS 서비스({})가 활성화되어 있습니다.".format(service_name))
        else:
            print("OK: DNS 서비스({})가 비활성화되어 있습니다.".format(service_name))
            
    except subprocess.CalledProcessError as e:
        print("ERROR: DNS 서비스 상태 확인 중 오류가 발생했습니다. (에러코드: {})".format(e.returncode))

if __name__ == "__main__":
    check_dns_service_status()
