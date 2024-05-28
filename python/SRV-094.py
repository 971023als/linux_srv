import os

# 파일 이름 설정 및 초기화
script_name = "SCRIPTNAME"  # 실제 스크립트 이름으로 변경해야 합니다.
tmp1 = f"{script_name}.log"

def bar():
    print("-" * 40)

def check_rsyslog_config():
    """`/etc/rsyslog.conf` 파일의 존재 여부 및 내용을 확인합니다."""
    filename = "/etc/rsyslog.conf"
    if not os.path.exists(filename):
        print(f"WARN: {filename} 가 존재하지 않습니다")
        return

    # 필요한 로그 설정 내용을 리스트로 정의합니다
    expected_content = [
        "*.info;mail.none;authpriv.none;cron.none /var/log/messages",
        "authpriv.* /var/log/secure",
        "mail.* /var/log/maillog",
        "cron.* /var/log/cron",
        "*.alert /dev/console",
        "*.emerg *",
    ]

    # 파일 내에서 각 설정이 존재하는지 확인합니다
    match = 0
    with open(filename, 'r') as file:
        content = file.read()
        for line in expected_content:
            if line in content:
                match += 1

    # 모든 필요한 설정이 존재하는지 결과를 출력합니다
    if match == len(expected_content):
        print(f"OK: {filename}의 내용이 정확합니다.")
    else:
        print(f"WARN: {filename}의 내용에 일부 설정이 누락되었습니다.")

def main():
    bar()

    print("[SRV-094] crontab 참조파일 권한 설정 미흡")

    result_msg = "[양호]: 로그 기록 정책이 정책에 따라 설정되어 수립되어 있는 경우\n[취약]: 로그 기록 정책이 정책에 따라 설정되어 수립되어 있지 않은 경우\n"
    bar()

    check_rsyslog_config()

    # 결과 메시지 출력
    print(result_msg)

if __name__ == "__main__":
    main()
