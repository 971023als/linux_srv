import os
import subprocess

# Python dictionary for JSON data
jsonData = {
    "분류": "시스템 보안",
    "코드": "SRV-013",
    "위험도": "중간",
    "진단항목": "Anonymous 계정의 FTP 서비스 접속 제한 미비",
    "현황": "Placeholder for Get-FTPAnonymousAccessRestrictionStatus function",
    "대응방안": "FTP 서비스에서 익명 계정의 접근을 엄격히 제한"
}

def bar():
    print("=" * 40)

def warn(message):
    return "WARNING: " + message

def ok(message):
    return "OK: " + message

# Define the log file path
log_file_name = os.path.basename(__file__) + '.log'

# Clear or create the log file
with open(log_file_name, 'w') as f:
    pass

bar()

code = "[SRV-013] Anonymous 계정의 FTP 서비스 접속 제한 미비"
with open(log_file_name, 'a') as f:
    f.write(f"{code}\n")
    f.write("[양호]: Anonymous FTP (익명 ftp) 접속을 차단한 경우\n")
    f.write("[취약]: Anonymous FTP (익명 ftp) 접속을 차단하지 않는 경우\n")

bar()

# Check /etc/passwd for ftp or anonymous account presence
if os.path.isfile("/etc/passwd"):
    with open("/etc/passwd", 'r') as passwd_file:
        users = passwd_file.read()
        if "ftp" in users or "anonymous" in users:
            file_exists_count = 0
            proftpd_conf_files = subprocess.getoutput("find / -name 'proftpd.conf' -type f 2>/dev/null").split('\n')
            vsftpd_conf_files = subprocess.getoutput("find / -name 'vsftpd.conf' -type f 2>/dev/null").split('\n')
            found_vuln = False
            
            # Check ProFTPD configurations
            for file in proftpd_conf_files:
                if file and os.path.isfile(file):
                    with open(file, 'r') as f:
                        content = f.read()
                        if '<Anonymous' in content and '</Anonymous>' in content:
                            result = warn(f"{file} 파일에서 익명 접속이 제한되지 않습니다.")
                            found_vuln = True
                            break
            
            # Check vsFTPd configurations
            for file in vsftpd_conf_files:
                if file and os.path.isfile(file):
                    with open(file, 'r') as f:
                        content = f.read()
                        if 'anonymous_enable=YES' in content:
                            result = warn(f"{file} 파일에서 익명 ftp 접속을 허용하고 있습니다.")
                            found_vuln = True
                            break
            
            if not found_vuln:
                result = ok("모든 FTP 설정에서 익명 접속이 제대로 차단되어 있습니다.")
        else:
            result = ok("Anonymous FTP (익명 ftp) 접속을 차단")
else:
    result = warn("/etc/passwd 파일이 존재하지 않습니다.")

with open(log_file_name, 'a') as f:
    f.write(result + "\n")

bar()

# Print results
with open(log_file_name, 'r') as f:
    print(f.read())
