import re
import os

def check_ftp_service_info_exposure():
    vsftpd_config = "/etc/vsftpd.conf"
    proftpd_config = "/etc/proftpd/proftpd.conf"

    # vsftpd 설정 검사
    if os.path.isfile(vsftpd_config):
        with open(vsftpd_config, 'r') as file:
            content = file.read()
            if re.search(r'ftpd_banner=', content, re.MULTILINE):
                print("OK: vsftpd에서 버전 정보 노출이 제한됩니다.")
            else:
                print("WARN: vsftpd에서 버전 정보가 노출됩니다.")
    else:
        print("INFO: vsftpd 설정 파일이 존재하지 않습니다.")

    # ProFTPD 설정 검사
    if os.path.isfile(proftpd_config):
        with open(proftpd_config, 'r') as file:
            content = file.read()
            if re.search(r'ServerIdent on "FTP Server ready."', content, re.MULTILINE):
                print("OK: ProFTPD에서 버전 정보 노출이 제한됩니다.")
            else:
                print("WARN: ProFTPD에서 버전 정보가 노출됩니다.")
    else:
        print("INFO: ProFTPD 설정 파일이 존재하지 않습니다.")

if __name__ == "__main__":
    check_ftp_service_info_exposure()
