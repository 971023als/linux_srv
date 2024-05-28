import os
import stat

def check_ftpusers_files():
    file_exists_count = 0
    ftpusers_files = [
        "/etc/ftpusers", "/etc/pure-ftpd/ftpusers", "/etc/wu-ftpd/ftpusers",
        "/etc/vsftpd/ftpusers", "/etc/proftpd/ftpusers", "/etc/ftpd/ftpusers",
        "/etc/vsftpd.ftpusers", "/etc/vsftpd.user_list", "/etc/vsftpd/user_list"
    ]
    
    for file_path in ftpusers_files:
        if os.path.isfile(file_path):
            file_exists_count += 1
            file_stat = os.stat(file_path)
            file_owner = os.getpwuid(file_stat.st_uid).pw_name
            file_permission = stat.S_IMODE(file_stat.st_mode)
            if file_owner == "root" and file_permission <= 0o640:
                print(f"OK: {file_path} 파일의 소유자는 root이고, 권한이 640 이하입니다.")
            else:
                print(f"WARN: {file_path} 파일의 소유자가 root가 아니거나, 권한이 640보다 큽니다.")
    
    if file_exists_count == 0:
        print("WARN: ftp 접근제어 파일이 없습니다.")
    else:
        print("※ U-63 결과 : 양호(Good)")

if __name__ == "__main__":
    check_ftpusers_files()
