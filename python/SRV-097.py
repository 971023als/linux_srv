import os
import subprocess

# 결과 파일 초기화 및 기본 정보 추가
script_name = "SCRIPTNAME"  # 실제 스크립트 이름으로 변경해야 합니다.
tmp1 = f"{script_name}.log"

with open(tmp1, 'w') as f:
    f.write("CODE [SRV-097] FTP 서비스 디렉터리 접근권한 설정 미흡\n\n")
    f.write("[양호]: FTP 서비스 디렉터리의 접근 권한이 적절하게 설정된 경우\n")
    f.write("[취약]: FTP 서비스 디렉터리의 접근 권한이 적절하지 않게 설정된 경우\n")
    f.write("\n------------------------------------------------------------\n")

def warn(message):
    with open(tmp1, 'a') as f:
        f.write(f"WARN: {message}\n")

def ok(message):
    with open(tmp1, 'a') as f:
        f.write(f"OK: {message}\n")

def check_ftp_service():
    # FTP 서비스 실행 중인지 확인
    result = subprocess.run(['ps', '-ef'], stdout=subprocess.PIPE, text=True)
    if 'ftp' in result.stdout:
        warn("ftp 서비스가 실행 중입니다.")
    else:
        ok("※ U-64 결과 : 양호(Good)")

def check_ftpusers_file_permissions(ftpusers_files):
    for file in ftpusers_files:
        if os.path.exists(file):
            stat_result = os.stat(file)
            mode = oct(stat_result.st_mode)[-3:]
            if mode > '640':
                warn(f"{file} 파일의 권한이 640보다 큽니다.")
            else:
                ok(f"{file} 파일의 권한 설정이 적절합니다.")

def main():
    ftpusers_files = ["/etc/ftpusers", "/etc/pure-ftpd/ftpusers", "/etc/wu-ftpd/ftpusers", "/etc/vsftpd/ftpusers", "/etc/proftpd/ftpusers", "/etc/ftpd/ftpusers", "/etc/vsftpd.ftpusers", "/etc/vsftpd.user_list", "/etc/vsftpd/user_list"]
    check_ftp_service()
    check_ftpusers_file_permissions(ftpusers_files)

if __name__ == "__main__":
    main()
