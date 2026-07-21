import os

# 결과 파일 초기화 및 기본 정보 추가
script_name = "SCRIPTNAME"  # 실제 스크립트 이름으로 변경해야 합니다.
tmp1 = f"{script_name}.log"

with open(tmp1, 'w') as f:
    f.write("CODE [SRV-109] 시스템 주요 이벤트 로그 설정 미흡\n\n")
    f.write("[양호]: 주요 이벤트 로그 설정이 적절하게 구성되어 있는 경우\n")
    f.write("[취약]: 주요 이벤트 로그 설정이 적절하게 구성되어 있지 않은 경우\n")
    f.write("\n------------------------------------------------------------\n")

def warn(message):
    with open(tmp1, 'a') as f:
        f.write(f"WARN: {message}\n")

def ok(message):
    with open(tmp1, 'a') as f:
        f.write(f"OK: {message}\n")

def check_log_settings(filename, expected_content):
    if not os.path.exists(filename):
        warn(f"{filename} 가 존재하지 않습니다")
        return

    match = 0
    with open(filename, 'r') as file:
        contents = file.read()
        for content in expected_content:
            if content in contents:
                match += 1

    if match == len(expected_content):
        ok(f"{filename}의 내용이 정확합니다.")
    else:
        warn(f"{filename}의 내용이 잘못되었습니다.")

def main():
    filename = "/etc/rsyslog.conf"
    expected_content = [
        "*.info;mail.none;authpriv.none;cron.none /var/log/messages",
        "authpriv.* /var/log/secure",
        "mail.* /var/log/maillog",
        "cron.* /var/log/cron",
        "*.alert /dev/console",
        "*.emerg *",
    ]
    check_log_settings(filename, expected_content)

if __name__ == "__main__":
    main()
