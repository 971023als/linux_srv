import os
import re
import subprocess

# Python dictionary for JSON data
jsonData = {
    "분류": "시스템 보안",
    "코드": "SRV-010",
    "위험도": "중간",
    "진단항목": "SMTP 서비스의 메일 queue 처리 권한 설정 미흡",
    "현황": "Placeholder for Get-SMTPQueueSettingsStatus function",
    "대응방안": "SMTP 서비스의 메일 queue 처리 권한을 업무 관리자에게만 부여"
}

def bar():
    print("=" * 40)

# Define the log file path
log_file_name = os.path.basename(__file__) + '.log'

# Clear or create the log file
with open(log_file_name, 'w') as log_file:
    log_file.truncate(0)

bar()

# Logging initial content to file
code = "[SRV-010] SMTP 서비스의 메일 queue 처리 권한 설정 미흡"
with open(log_file_name, 'a') as log_file:
    log_file.write(f"{code}\n")
    log_file.write("[양호]: SMTP 서비스의 메일 queue 처리 권한을 업무 관리자에게만 부여되도록 설정한 경우\n")
    log_file.write("[취약]: SMTP 서비스의 메일 queue 처리 권한이 업무와 무관한 일반 사용자에게도 부여되도록 설정된 경우\n")

bar()

# Check Sendmail settings
sendmail_cf = "/etc/mail/sendmail.cf"
try:
    with open(sendmail_cf, 'r') as file:
        content = file.read()
        if re.search("O PrivacyOptions=.*restrictqrun", content):
            result = "OK: Sendmail의 PrivacyOptions에 restrictqrun 설정이 적용되어 있습니다."
        else:
            result = "WARN: Sendmail의 PrivacyOptions에 restrictqrun 설정이 누락되었습니다."
except FileNotFoundError:
    result = "INFO: Sendmail 설정 파일이 존재하지 않습니다."

with open(log_file_name, 'a') as log_file:
    log_file.write(result + "\n")

# Check Postfix mail queue directory permissions
postsuper = "/usr/sbin/postsuper"
if os.path.exists(postsuper) and os.access(postsuper, os.X_OK):
    # Check others' permissions
    perm = oct(os.stat(postsuper).st_mode)[-3:]
    if perm == "750":
        result = "OK: Postfix의 postsuper 실행 파일이 others에 대해 실행 권한이 없습니다."
    else:
        result = "WARN: Postfix의 postsuper 실행 파일이 others에 대해 과도한 권한을 부여하고 있습니다."
else:
    result = "INFO: Postfix postsuper 실행 파일이 존재하지 않습니다."

with open(log_file_name, 'a') as log_file:
    log_file.write(result + "\n")

# Display the log file content
with open(log_file_name, 'r') as log_file:
    print(log_file.read())
