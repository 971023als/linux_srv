import os
import stat

# Python dictionary for JSON data
jsonData = {
    "분류": "시스템 보안",
    "코드": "SRV-021",
    "위험도": "중간",
    "진단항목": "FTP 서비스 접근 제어 설정 미비",
    "진단결과": "(변수: 양호, 취약, 정보 미확인)",
    "현황": "Placeholder for Check-FTPAccessControl function",
    "대응방안": "ftpusers 파일의 소유자를 관리자로 설정하고, 권한을 640 이하로 제한하세요."
}

def bar():
    print("=" * 40)

def warn(message):
    return f"WARNING: {message}\n"

def ok(message):
    return f"OK: {message}\n"

# Define the log file path
log_file_name = "ftp_access_audit.log"  # Updated script name

# Clear or create the log file
with open(log_file_name, 'w') as f:
    pass

bar()

code = "[SRV-021] FTP 서비스 접근 제어 설정 미비"
with open(log_file_name, 'a') as f:
    f.write(f"{code}\n")
    f.write("[양호]: ftpusers 파일의 소유자가 root이고, 권한이 640 이하인 경우\n")
    f.write("[취약]: ftpusers 파일의 소유자가 root가 아니고, 권한이 640 이상인 경우\n")

bar()

# List of potential FTP service configuration files
ftpusers_files = [
    "/etc/ftpusers", "/etc/pure-ftpd/ftpusers", "/etc/wu-ftpd/ftpusers", "/etc/vsftpd/ftpusers",
    "/etc/proftpd/ftpusers", "/etc/ftpd/ftpusers", "/etc/vsftpd.ftpusers", "/etc/vsftpd.user_list", "/etc/vsftpd/user_list"
]

results = []
file_exists_count = 0

for file_path in ftpusers_files:
    if os.path.isfile(file_path):
        file_exists_count += 1
        file_stat = os.stat(file_path)
        mode = file_stat.st_mode
        owner = file_stat.st_uid

        if owner == 0 and (mode & 0o770) <= 0o640:
            results.append(ok(f"{file_path} 파일의 설정이 양호합니다."))
        else:
            if owner != 0:
                results.append(warn(f"{file_path} 파일의 소유자(owner)가 root가 아닙니다."))
            if (mode & 0o770) > 0o640:
                results.append(warn(f"{file_path} 파일의 권한이 640보다 큽니다."))

if file_exists_count == 0:
    results.append(warn("ftp 접근제어 파일이 없습니다."))

# Write results to the log file
with open(log_file_name, 'a') as f:
    for result in results:
        f.write(result)

bar()

# Print results
with open(log_file_name, 'r') as f:
    print(f.read())
