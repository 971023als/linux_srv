import subprocess
import os

# Python dictionary for JSON data
jsonData = {
    "분류": "시스템 보안",
    "코드": "SRV-020",
    "위험도": "중간",
    "진단항목": "공유에 대한 접근 통제 미비",
    "진단결과": "(변수: 양호, 취약, 정보 미확인)",
    "대응방안": "적절한 공유 접근 통제 설정을 통해 보안을 강화하세요."
}

def bar():
    print("=" * 40)

def warn(message):
    return f"WARNING: {message}\n"

def ok(message):
    return f"OK: {message}\n"

def info(message):
    return f"INFO: {message}\n"

# Define the log file path
log_file_name = "share_access_audit.log"

# Clear or create the log file
with open(log_file_name, 'w') as f:
    pass

bar()

code = "[SRV-020] 공유에 대한 접근 통제 미비"
with open(log_file_name, 'a') as f:
    f.write(f"{code}\n")
    f.write("[양호]: NFS 또는 SMB/CIFS 공유에 대한 접근 통제가 적절하게 설정된 경우\n")
    f.write("[취약]: NFS 또는 SMB/CIFS 공유에 대한 접근 통제가 미비한 경우\n")

bar()

# Check access control settings for NFS and SMB/CIFS
NFS_EXPORTS_FILE = "/etc/exports"
SMB_CONF_FILE = "/etc/samba/smb.conf"

def check_access_control(file, service_name):
    if os.path.isfile(file):
        with open(file, 'r') as f:
            content = f.read().lower()
            if "everyone" in content or "public" in content:
                return warn(f"{service_name} 서비스에서 느슨한 공유 접근 통제가 발견됨: {file}")
            else:
                return ok(f"{service_name} 서비스에서 공유 접근 통제가 적절함: {file}")
    else:
        return info(f"{service_name} 서비스 설정 파일({file})을 찾을 수 없습니다.")

def check_share_listings(service_check_command, service_name):
    try:
        subprocess.check_output(service_check_command, shell=True, stderr=subprocess.STDOUT)
        return warn(f"{service_name} 서비스에서 공유 목록이 발견됨")
    except subprocess.CalledProcessError:
        return ok(f"{service_name} 서비스에서 공유 목록이 발견되지 않음")

with open(log_file_name, 'a') as f:
    f.write(check_access_control(NFS_EXPORTS_FILE, "NFS"))
    f.write(check_access_control(SMB_CONF_FILE, "SMB/CIFS"))
    f.write(check_share_listings("showmount -e localhost", "NFS"))
    f.write(check_share_listings("smbclient -L localhost -N", "SMB/CIFS"))

bar()

# Print results
with open(log_file_name, 'r') as f:
    print(f.read())
