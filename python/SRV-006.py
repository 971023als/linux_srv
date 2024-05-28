import os
import subprocess

# Dictionary for storing configuration and status information
jsonData = {
    "분류": "시스템 보안",
    "코드": "SRV-006",
    "위험도": "중간",
    "진단항목": "SMTP 서비스 로그 수준 설정 미흡",
    "현황": "Placeholder for Get-SMTPLogLevelStatus function",
    "대응방안": "SMTP 서비스의 로그 수준을 '중간' 또는 '높음'으로 설정"
}

# Define the path for the log file
log_file_name = os.path.basename(__file__) + '.log'

# Clear the log file or create it if it doesn't exist
with open(log_file_name, 'w') as log_file:
    log_file.truncate(0)

def log_message(message, is_bar=False):
    with open(log_file_name, 'a') as log_file:
        if is_bar:
            log_file.write("=" * 40 + "\n")
        else:
            log_file.write(f"{message}\n")

def check_log_level_setting(config_file, setting_key):
    if os.path.isfile(config_file):
        with open(config_file, 'r') as file:
            lines = file.readlines()
            log_level = None
            for line in lines:
                if line.startswith(setting_key):
                    log_level = line.strip().split()[2]
                    break
            if log_level and int(log_level) >= 9:
                return f"OK: SMTP 서비스의 로그 수준이 적절하게 설정됨 (현재 수준: {log_level})."
            else:
                return f"WARN: SMTP 서비스의 로그 수준이 낮게 설정됨 (현재 수준: {log_level if log_level else '미설정'})."
    else:
        return f"INFO: sendmail 구성 파일({config_file})을 찾을 수 없습니다."

# Main logging logic
log_message(None, is_bar=True)
log_message("CODE [SRV-006] SMTP 서비스 로그 수준 설정 미흡")
log_message("[양호]: SMTP 서비스의 로그 수준이 적절하게 설정되어 있는 경우\n[취약]: SMTP 서비스의 로그 수준이 낮거나, 로그가 충분히 수집되지 않는 경우")
log_message(None, is_bar=True)
log_message("\"[SRV-006] SMTP 서비스 로그 수준 설정 미흡\"")

# Configuration file and LogLevel setting
sendmail_config = "/etc/mail/sendmail.cf"
log_level_setting = "O LogLevel"

# Execute log level check
log_level_result = check_log_level_setting(sendmail_config, log_level_setting)
log_message(log_level_result)
log_message(None, is_bar=True)

# Display the log file content
with open(log_file_name, 'r') as log_file:
    print(log_file.read())
