import os
import re
import subprocess

# Python dictionary for JSON data
jsonData = {
    "분류": "시스템 보안",
    "코드": "SRV-009",
    "위험도": "중간",
    "진단항목": "SMTP 서비스 스팸 메일 릴레이 제한 미설정",
    "현황": "Placeholder for Get-SMTPRelaySettingsStatus function",
    "대응방안": "SMTP 포트의 릴레이 설정을 적절히 조정"
}

def BAR():
    print("=" * 40)

def WARN(message):
    return "WARNING: " + message

def OK(message):
    return "OK: " + message

# Define the log file path
log_file_name = os.path.basename(__file__) + '.log'

# Clear or create the log file
with open(log_file_name, 'w') as log_file:
    log_file.truncate(0)

BAR()

# Writing initial setup to log
code = "[SRV-009] SMTP 서비스 스팸 메일 릴레이 제한 미설정"
with open(log_file_name, 'a') as log_file:
    log_file.write(f"{code}\n")
    log_file.write("[양호]: SMTP 서비스를 사용하지 않거나 릴레이 제한이 설정되어 있는 경우\n")
    log_file.write("[취약]: SMTP 서비스를 사용하거나 릴레이 제한이 설정되지 않은 경우\n")

BAR()

# Check SMTP relay restrictions
if os.path.isfile('/etc/services'):
    smtp_ports = [line.split()[1].split('/')[0] for line in open('/etc/services') if 'smtp' in line.lower() and 'tcp' in line]
    if smtp_ports:
        for port in smtp_ports:
            netstat_output = subprocess.getoutput(f"netstat -nat | grep -w 'tcp' | grep -E 'LISTEN|ESTABLISHED|SYN_SENT|SYN_RECEIVED' | grep ':{port} '")
            if netstat_output:
                sendmail_cf_files = subprocess.getoutput("find / -name 'sendmail.cf' -type f 2>/dev/null").split('\n')
                for file in sendmail_cf_files:
                    with open(file, 'r') as f:
                        content = f.read()
                        if 'R$*' in content and 'Relaying denied' not in content:
                            with open(log_file_name, 'a') as log_file:
                                log_file.write(WARN(f"{file} 파일에 릴레이 제한이 설정되어 있지 않습니다.\n"))
                                break

smtp_process_count = subprocess.getoutput("ps -ef | grep -iE 'smtp|sendmail' | grep -v 'grep'").count('\n')
if smtp_process_count > 0:
    with open(log_file_name, 'a') as log_file:
        log_file.write(WARN("SMTP 서비스가 실행 중이며 릴레이 제한이 없을 수 있습니다.\n"))
else:
    with open(log_file_name, 'a') as log_file:
        log_file.write(OK("SMTP 서비스를 사용하지 않거나 릴레이 제한이 설정되어 있습니다.\n"))

# Display the log file content
with open(log_file_name, 'r') as log_file:
    print(log_file.read())
