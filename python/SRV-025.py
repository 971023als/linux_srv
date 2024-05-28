import os
import stat
import pwd
import subprocess

# Python dictionary for JSON data
jsonData = {
    "분류": "시스템 보안",
    "코드": "SRV-025",
    "위험도": "중간",
    "진단항목": "SSH 서비스 및 hosts 파일 설정",
    "진단결과": "(변수: 양호, 취약)",
    "현황": "Placeholder for Get-SSHAndHostsStatus function",
    "대응방안": "SSH 설정을 강화하고, 불필요한 hosts 파일은 삭제하거나 보안을 강화하세요."
}

def bar():
    print("=" * 40)

def log_message(message, file_path):
    with open(file_path, 'a') as file:
        file.write(message + "\n")

# Define the log file path
log_file_name = "ssh_and_hosts_audit.log"

# Clear or create the log file
with open(log_file_name, 'w') as file:
    pass

bar()

code = "[SRV-025] 취약한 hosts.equiv 또는 .rhosts 설정 존재"
log_message(f"{code}\n[양호]: hosts.equiv 및 .rhosts 파일이 없거나, 안전하게 구성된 경우\n[취약]: hosts.equiv 또는 .rhosts 파일에 취약한 설정이 있는 경우\n", log_file_name)

bar()

# Check hosts.equiv and .rhosts files
host_files = ["/etc/hosts.equiv"]
user_dirs = [user.pw_dir for user in pwd.getpwall() if user.pw_shell not in ("/bin/false", "/sbin/nologin") and os.path.isdir(user.pw_dir)]

# Include home directories if not covered
user_dirs += [os.path.join("/home", d) for d in os.listdir("/home") if os.path.isdir(os.path.join("/home", d))]

# Adding .rhosts in all user directories
host_files += [os.path.join(dir_path, ".rhosts") for dir_path in user_dirs]

for host_file in host_files:
    if os.path.isfile(host_file):
        with open(host_file, 'r') as file:
            content = file.read()
        file_stat = os.stat(host_file)
        if (file_stat.st_uid == 0 and oct(file_stat.st_mode & 0o777) in ['0600', '0400']) or (file_stat.st_uid != 0 and oct(file_stat.st_mode & 0o777) == '0000'):
            message = OK(f"{host_file} 파일이 안전하게 구성되어 있습니다.") if '+' not in content else WARN(f"{host_file} 파일에 '+' 설정이 있습니다.")
        else:
            message = WARN(f"{host_file} 파일의 권한이 취약합니다.")
    else:
        message = INFO(f"{host_file} 파일이 존재하지 않습니다.")
    log_message(message, log_file_name)

bar()

# Print results
with open(log_file_name, 'r') as file:
    print(file.read())
