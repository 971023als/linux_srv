import os
import stat
import subprocess

# 결과 파일 초기화
script_name = "SCRIPTNAME.log"  # 실제 스크립트 이름으로 변경해야 합니다.

def write_result(message):
    with open(script_name, 'a') as f:
        f.write(message + "\n")

def check_crontab_permissions():
    crontab_paths = ["/usr/bin/crontab", "/usr/sbin/crontab", "/bin/crontab"]
    crontab_found = False

    for path in crontab_paths:
        if os.path.exists(path):
            crontab_found = True
            mode = os.stat(path).st_mode
            if not (mode & stat.S_IWGRP) and not (mode & stat.S_IWOTH):
                write_result(f"OK: {path} 명령어의 권한이 적절합니다.")
            else:
                write_result(f"WARN: {path} 명령어의 권한이 취약합니다.")

    if not crontab_found:
        write_result("WARN: crontab 명령어가 시스템에 설치되어 있지 않습니다.")

def check_cron_files_permissions():
    cron_dirs = ["/etc/cron.hourly", "/etc/cron.daily", "/etc/cron.weekly", "/etc/cron.monthly", "/var/spool/cron", "/var/spool/cron/crontabs"]
    cron_files = ["/etc/crontab", "/etc/cron.allow", "/etc/cron.deny"]

    for dir in cron_dirs:
        if os.path.isdir(dir):
            for root, dirs, files in os.walk(dir):
                for name in files:
                    cron_files.append(os.path.join(root, name))

    for file in cron_files:
        if os.path.exists(file):
            mode = os.stat(file).st_mode
            if (mode & stat.S_IRWXU) == stat.S_IRWXU and (mode & stat.S_IRWXG) == 0 and (mode & stat.S_IRWXO) == 0:
                write_result(f"OK: {file} 파일의 권한이 적절합니다.")
            else:
                write_result(f"WARN: {file} 파일의 권한이 취약합니다.")

def main():
    open(script_name, 'w').close()  # 결과 파일 초기화
    check_crontab_permissions()
    check_cron_files_permissions()

if __name__ == "__main__":
    main()
