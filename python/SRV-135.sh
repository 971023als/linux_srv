import subprocess

# 결과 파일 초기화
script_name = "SCRIPTNAME.log"  # 실제 스크립트 이름으로 변경해야 합니다.

def write_result(message):
    with open(script_name, 'a') as f:
        f.write(message + "\n")

def check_tcp_security_settings():
    tcp_settings = [
        "net.ipv4.tcp_syncookies",
        "net.ipv4.tcp_max_syn_backlog",
        "net.ipv4.tcp_synack_retries",
        "net.ipv4.tcp_syn_retries"
    ]

    for setting in tcp_settings:
        try:
            value = subprocess.check_output(['sysctl', setting], text=True).strip()
            write_result(f"OK: {setting} 설정이 존재합니다: {value}")
        except subprocess.CalledProcessError as e:
            write_result(f"WARN: {setting} 설정이 없습니다.")

def main():
    open(script_name, 'w').close()  # 결과 파일 초기화
    check_tcp_security_settings()

if __name__ == "__main__":
    main()
