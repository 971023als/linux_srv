import subprocess

# 결과 파일 초기화
script_name = "SCRIPTNAME.log"  # 실제 스크립트 이름으로 변경해야 합니다.

def write_result(message):
    with open(script_name, 'a') as f:
        f.write(message + "\n")

def check_system_updates():
    try:
        result = subprocess.run(['apt-get', '-s', 'upgrade'], stdout=subprocess.PIPE, text=True)
        update_status = result.stdout
        if "0 upgraded" in update_status:
            write_result("OK: 모든 패키지가 최신 상태입니다.")
        else:
            write_result(f"WARN: 일부 패키지가 업데이트되지 않았습니다: {update_status.splitlines()[1]}")
    except Exception as e:
        write_result(f"ERROR: 시스템 업데이트 상태 확인 중 오류 발생: {e}")

def check_security_policy():
    policy_file = "/etc/security/policies.conf"
    try:
        with open(policy_file, 'r') as f:
            policy_content = f.read()
        if "important_security_policy" in policy_content:
            write_result("OK: 중요 보안 정책이 설정됨")
        else:
            write_result("WARN: 중요 보안 정책이 /etc/security/policies.conf에 설정되지 않음")
    except FileNotFoundError:
        write_result("WARN: /etc/security/policies.conf 파일이 존재하지 않음")

def main():
    open(script_name, 'w').close()  # 결과 파일 초기화
    check_system_updates()
    check_security_policy()

if __name__ == "__main__":
    main()
