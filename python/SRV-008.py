import os
import re

# Python dictionary for JSON data
jsonData = {
    "분류": "시스템 보안",
    "코드": "SRV-008",
    "위험도": "중간",
    "진단항목": "SMTP 서비스의 DoS 방지 기능 미설정",
    "현황": "Placeholder for Get-SMTPDoSSettingsStatus function",
    "대응방안": "SMTP 서비스에 DoS 방지 설정을 적용"
}

# Define the path for the log file
log_file_name = os.path.basename(__file__) + '.log'

# Clear or create log file
with open(log_file_name, 'w') as f:
    f.truncate(0)

def bar():
    with open(log_file_name, 'a') as f:
        f.write("================================\n")

bar()

# Writing initial setup to log
with open(log_file_name, 'a') as f:
    code = "[SRV-008] SMTP 서비스의 DoS 방지 기능 미설정"
    f.write(f"{code}\n")
    f.write("[양호]: SMTP 서비스에 DoS 방지 설정이 적용된 경우\n")
    f.write("[취약]: SMTP 서비스에 DoS 방지 설정이 적용되지 않은 경우\n")

bar()

# Check settings in Sendmail configuration
sendmail_cf = "/etc/mail/sendmail.cf"
sendmail_settings = ["MaxDaemonChildren", "ConnectionRateThrottle", "MinFreeBlocks", "MaxHeadersLength", "MaxMessageSize"]

with open(log_file_name, 'a') as f:
    f.write("Sendmail DoS 방지 설정을 점검 중입니다...\n")
    if os.path.isfile(sendmail_cf):
        with open(sendmail_cf, 'r') as file:
            content = file.read()
            for setting in sendmail_settings:
                if re.search(rf"^O\s*{setting}=", content, re.MULTILINE):
                    f.write(f"OK: {setting} 설정이 적용되었습니다.\n")
                else:
                    f.write(f"WARN: {setting} 설정이 적용되지 않았습니다.\n")
    else:
        f.write("INFO: Sendmail 설정 파일이 존재하지 않습니다.\n")

# Check settings in Postfix configuration
postfix_main_cf = "/etc/postfix/main.cf"
postfix_settings = ["message_size_limit", "header_size_limit", "default_process_limit", "local_destination_concurrency_limit", "smtpd_recipient_limit"]

with open(log_file_name, 'a') as f:
    f.write("Postfix DoS 방지 설정을 점검 중입니다...\n")
    if os.path.isfile(postfix_main_cf):
        with open(postfix_main_cf, 'r') as file:
            content = file.readlines()
            for setting in postfix_settings:
                if any(re.match(rf"^{setting}\s*=", line) for line in content):
                    f.write(f"OK: {setting} 설정이 적용되었습니다.\n")
                else:
                    f.write(f"WARN: {setting} 설정이 명시적으로 구성되지 않았습니다(기본값 사용 가능).\n")
    else:
        f.write("INFO: Postfix 설정 파일이 존재하지 않습니다.\n")

bar()

# Display the log file content
with open(log_file_name, 'r') as f:
    print(f.read())
