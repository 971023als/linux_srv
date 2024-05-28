import subprocess
import pwd

# 결과 파일 초기화 및 기본 정보 추가
script_name = "SCRIPTNAME"  # 실제 스크립트 이름으로 변경해야 합니다.
tmp1 = f"{script_name}.log"

with open(tmp1, 'w') as f:
    f.write("CODE [SRV-101] 불필요한 예약된 작업 존재\n\n")
    f.write("[양호]: 불필요한 cron 작업이 존재하지 않는 경우\n")
    f.write("[취약]: 불필요한 cron 작업이 존재하는 경우\n")
    f.write("\n------------------------------------------------------------\n")

def warn(message):
    with open(tmp1, 'a') as f:
        f.write(f"WARN: {message}\n")

def ok(message):
    with open(tmp1, 'a') as f:
        f.write(f"OK: {message}\n")

def check_cron_jobs():
    # 시스템에 등록된 모든 사용자에 대해 cron 작업 검사
    cron_exists = False
    for user in pwd.getpwall():
        try:
            cron_jobs = subprocess.check_output(['crontab', '-l', '-u', user.pw_name], stderr=subprocess.DEVNULL).decode('utf-8')
            for line in cron_jobs.split('\n'):
                if line and not line.startswith('#'):
                    warn(f"불필요한 cron 작업이 존재할 수 있습니다: {line} (사용자: {user.pw_name})")
                    cron_exists = True
        except subprocess.CalledProcessError:
            # crontab이 없는 사용자의 경우 예외 처리
            pass
    if not cron_exists:
        ok("불필요한 cron 작업이 존재하지 않습니다.")

def main():
    check_cron_jobs()

if __name__ == "__main__":
    main()
