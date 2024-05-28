import os

# Python dictionary for JSON data
jsonData = {
    "분류": "시스템 보안",
    "코드": "SRV-011",
    "위험도": "중간",
    "진단항목": "시스템 관리자 계정의 FTP 사용 제한 미비",
    "현황": "Placeholder for Get-FTPAdminAccessRestrictionStatus function",
    "대응방안": "FTP 서비스에서 시스템 관리자 계정의 접근을 엄격히 제한"
}

def bar():
    print("=" * 40)

# Define the log file path
log_file_name = os.path.basename(__file__) + '.log'

# Clear or create the log file
with open(log_file_name, 'w') as f:
    pass

bar()

# Logging initial content to the file
code = "[SRV-011] 시스템 관리자 계정의 FTP 사용 제한 미비"
with open(log_file_name, 'a') as f:
    f.write(f"{code}\n")
    f.write("[양호]: FTP 서비스에서 시스템 관리자 계정의 접근이 제한되는 경우\n")
    f.write("[취약]: FTP 서비스에서 시스템 관리자 계정의 접근이 제한되지 않는 경우\n")

bar()

# FTP users restriction file path
ftp_users_file = "/etc/vsftpd/ftpusers"

# Check for 'root' account access restriction in FTP
if os.path.isfile(ftp_users_file):
    with open(ftp_users_file, 'r') as file:
        contents = file.read()
        if "root" in contents:
            result = "OK: FTP 서비스에서 root 계정의 접근이 제한됩니다."
        else:
            result = "WARN: FTP 서비스에서 root 계정의 접근이 제한되지 않습니다."
else:
    result = "WARN: FTP 사용자 제한 설정 파일({})이 존재하지 않습니다.".format(ftp_users_file)

with open(log_file_name, 'a') as f:
    f.write(result + "\n")

# Display the log file content
with open(log_file_name, 'r') as f:
    print(f.read())
