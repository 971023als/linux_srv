import os

# 결과 파일 초기화 및 기본 정보 추가
script_name = "SCRIPTNAME"  # 실제 스크립트 이름으로 변경해야 합니다.
tmp1 = f"{script_name}.log"

with open(tmp1, 'w') as f:
    f.write("CODE [SRV-112] Cron 서비스 로깅 미설정\n\n")
    f.write("[양호]: Cron 서비스 로깅이 적절하게 설정되어 있는 경우\n")
    f.write("[취약]: Cron 서비스 로깅이 적절하게 설정되어 있지 않은 경우\n")
    f.write("\n------------------------------------------------------------\n")

def check_cron_logging():
    rsyslog_conf = "/etc/rsyslog.conf"
    cron_log = "/var/log/cron"
    
    # rsyslog.conf 파일에서 Cron 로깅 설정 확인
    if not os.path.isfile(rsyslog_conf):
        with open(tmp1, 'a') as f:
            f.write("WARN: rsyslog.conf 파일이 존재하지 않습니다.\n")
    else:
        with open(rsyslog_conf, 'r') as file:
            if "cron.*" in file.read():
                with open(tmp1, 'a') as f:
                    f.write("OK: Cron 로깅이 rsyslog.conf에서 설정되었습니다.\n")
            else:
                with open(tmp1, 'a') as f:
                    f.write("WARN: Cron 로깅이 rsyslog.conf에서 설정되지 않았습니다.\n")
    
    # Cron 로그 파일 존재 여부 확인
    if not os.path.isfile(cron_log):
        with open(tmp1, 'a') as f:
            f.write("WARN: Cron 로그 파일이 존재하지 않습니다.\n")
    else:
        with open(tmp1, 'a') as f:
            f.write("OK: Cron 로그 파일이 존재합니다.\n")

def main():
    check_cron_logging()

if __name__ == "__main__":
    main()
