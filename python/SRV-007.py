import os
import subprocess
from packaging import version

# Python dictionary for JSON data
jsonData = {
    "분류": "시스템 보안",
    "코드": "SRV-007",
    "위험도": "중간",
    "진단항목": "취약한 버전의 SMTP 서비스 사용",
    "현황": "Placeholder for Get-SMTPServiceVersionStatus function",
    "대응방안": "SMTP 서비스를 최신 버전으로 업데이트"
}

# Define the path for the log file
log_file_name = os.path.basename(__file__) + '.log'

# Clear the log file or create it if it doesn't exist
with open(log_file_name, 'w') as log_file:
    log_file.truncate(0)

def bar():
    with open(log_file_name, 'a') as log_file:
        log_file.write("=" * 40 + "\n")

def append_to_log(message):
    with open(log_file_name, 'a') as log_file:
        log_file.write(f"{message}\n")

# Append initial content
bar()
append_to_log("CODE [SRV-007] 취약한 버전의 SMTP 서비스 사용")
append_to_log("[양호]: SMTP 서비스 버전이 최신 버전일 경우 또는 취약점이 없는 버전을 사용하는 경우\n[취약]: SMTP 서비스 버전이 최신이 아니거나 알려진 취약점이 있는 버전을 사용하는 경우")
bar()
append_to_log("[SRV-007] 취약한 버전의 SMTP 서비스 사용")

def version_gt(a, b):
    return version.parse(a) > version.parse(b)

# Check Sendmail version
try:
    sendmail_version = subprocess.check_output("sendmail -d0.1 -bt < /dev/null 2>&1 | grep Version | awk '{print $2}'", shell=True, text=True).strip()
    sendmail_min_version = "8.14.9"
    if sendmail_version and version_gt(sendmail_version, sendmail_min_version):
        append_to_log(f"OK: Sendmail 버전이 안전합니다. 현재 버전: {sendmail_version}")
    else:
        append_to_log(f"WARN: Sendmail 버전이 취약합니다. 현재 버전: {sendmail_version}, 권장 최소 버전: {sendmail_min_version}")
except subprocess.CalledProcessError:
    append_to_log("INFO: Sendmail이 설치되어 있지 않습니다.")

# Check Postfix version
try:
    postfix_version = subprocess.check_output("postconf mail_version", shell=True, text=True).strip()
    postfix_min_version = "3.0"  # example minimum safe version
    if postfix_version and version_gt(postfix_version, postfix_min_version):
        append_to_log(f"OK: Postfix 버전이 안전합니다. 현재 버전: {postfix_version}")
    else:
        append_to_log(f"WARN: Postfix 버전이 취약할 수 있습니다. 현재 버전: {postfix_version}, 권장 최소 버전: {postfix_min_version}")
except subprocess.CalledProcessError:
    append_to_log("INFO: Postfix가 설치되어 있지 않습니다.")

bar()

# Display the log file content
with open(log_file_name, 'r') as log_file:
    print(log_file.read())
