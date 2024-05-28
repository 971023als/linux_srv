import os
import subprocess

# Python dictionary for JSON data
jsonData = {
    "분류": "시스템 보안",
    "코드": "SRV-012",
    "위험도": "중간",
    "진단항목": ".netrc 파일 내 중요 정보 노출",
    "현황": "Placeholder for Get-NetrcFileStatus function",
    "대응방안": "시스템 전체에서 .netrc 파일을 제거하거나 적절한 권한 설정 적용"
}

def bar():
    print("=" * 40)

# Define the log file path
log_file_name = os.path.basename(__file__) + '.log'

# Clear or create the log file
with open(log_file_name, 'w') as f:
    f.truncate(0)

bar()

# Logging initial content to the file
code = "[SRV-012] .netrc 파일 내 중요 정보 노출"
with open(log_file_name, 'a') as f:
    f.write(f"{code}\n")
    f.write("[양호]: 시스템 전체에서 .netrc 파일이 존재하지 않는 경우\n")
    f.write("[취약]: 시스템 전체에서 .netrc 파일이 존재하는 경우\n")

bar()

# Find .netrc files across the system
try:
    netrc_files = subprocess.check_output(["find", "/", "-name", ".netrc", "-type", "f"], stderr=subprocess.DEVNULL).decode('utf-8').strip().split('\n')
except subprocess.CalledProcessError:
    netrc_files = []

if not netrc_files or not netrc_files[0]:  # Check if the list is empty or contains an empty string
    with open(log_file_name, 'a') as f:
        f.write("OK: 시스템에 .netrc 파일이 존재하지 않습니다.\n")
else:
    with open(log_file_name, 'a') as f:
        f.write("WARN: 다음 위치에 .netrc 파일이 존재합니다: {}\n".format(", ".join(netrc_files)))
        # Check permissions of .netrc files and log them
        for file in netrc_files:
            if file:  # Ensure the file string is not empty
                permissions = oct(os.stat(file).st_mode)[-3:]
                f.write("권한 확인: {} {}\n".format(file, permissions))

bar()

# Display the log file content
with open(log_file_name, 'r') as f:
    print(f.read())
