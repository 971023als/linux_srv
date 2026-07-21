import os

# 결과 파일 초기화 및 기본 정보 추가
script_name = "SCRIPTNAME"  # 실제 스크립트 이름으로 변경해야 합니다.
tmp1 = f"{script_name}.log"

with open(tmp1, 'w') as f:
    f.write("CODE [SRV-108] 로그에 대한 접근통제 및 관리 미흡\n\n")
    f.write("[양호]: 로그 파일의 접근 통제 및 관리가 적절하게 설정되어 있는 경우\n")
    f.write("[취약]: 로그 파일의 접근 통제 및 관리가 적절하게 설정되어 있지 않은 경우\n")
    f.write("\n------------------------------------------------------------\n")

filename = "/etc/rsyslog.conf"

def check_log_management():
    if not os.path.exists(filename):
        with open(tmp1, 'a') as f:
            f.write(f"WARN: {filename} 가 존재하지 않습니다\n")
        return

    expected_content = [
        "*.info;mail.none;authpriv.none;cron.none /var/log/messages",
        "authpriv.* /var/log/secure",
        "mail.* /var/log/maillog",
        "cron.* /var/log/cron",
        "*.alert /dev/console",
        "*.emerg *",
    ]

    match = 0
    with open(filename, 'r') as file:
        contents = file.read()
        for content in expected_content:
            if content in contents:
                match += 1

    if match == len(expected_content):
        with open(tmp1, 'a') as f:
            f.write(f"OK: {filename}의 내용이 정확합니다.\n")
    else:
        with open(tmp1, 'a') as f:
            f.write(f"WARN: {filename}의 내용이 잘못되었습니다.\n")

def main():
    check_log_management()

if __name__ == "__main__":
    main()
