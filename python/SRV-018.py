import os

# Python dictionary for JSON data
jsonData = {
    "분류": "시스템 보안",
    "코드": "SRV-018",
    "위험도": "중간",
    "진단항목": "하드디스크 기본 공유 활성화 상태",
    "진단결과": "(변수: 양호, 취약, 정보 미확인)",
    "대응방안": "NFS와 SMB/CIFS에서 불필요한 하드디스크 기본 공유를 비활성화하세요."
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
log_file_name = "disk_share_audit.log"  # Updated script name

# Clear or create the log file
with open(log_file_name, 'w') as f:
    pass

bar()

code = "[SRV-018] 불필요한 하드디스크 기본 공유 활성화"
with open(log_file_name, 'a') as f:
    f.write(f"{code}\n")
    f.write("[양호]: NFS 또는 SMB/CIFS의 불필요한 하드디스크 공유가 비활성화된 경우\n")
    f.write("[취약]: NFS 또는 SMB/CIFS에서 불필요한 하드디스크 기본 공유가 활성화된 경우\n")

bar()

# NFS and SMB/CIFS configuration files
NFS_EXPORTS_FILE = "/etc/exports"
SMB_CONF_FILE = "/etc/samba/smb.conf"

def check_share_activation(file, service_name):
    result = ""
    if os.path.isfile(file):
        with open(file, 'r') as f:
            lines = f.readlines()
            if any('/' in line.strip() for line in lines if not line.strip().startswith('#')):
                result += warn(f"{service_name} 서비스에서 불필요한 공유가 활성화되어 있습니다: {file}")
            else:
                result += ok(f"{service_name} 서비스에서 불필요한 공유가 비활성화되어 있습니다: {file}")
    else:
        result += info(f"{service_name} 서비스 설정 파일({file})을 찾을 수 없습니다.")
    return result

with open(log_file_name, 'a') as f:
    f.write(check_share_activation(NFS_EXPORTS_FILE, "NFS"))
    f.write(check_share_activation(SMB_CONF_FILE, "SMB/CIFS"))

bar()

# Print results
with open(log_file_name, 'r') as f:
    print(f.read())
