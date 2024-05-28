import subprocess

# 파일 이름 설정 및 초기화
script_name = "SCRIPTNAME"  # 실제 스크립트 이름으로 변경해야 합니다.
tmp1 = f"{script_name}.log"

def bar():
    print("-" * 40)

def check_files_without_owner_or_group():
    """소유자나 그룹이 존재하지 않는 파일 또는 디렉터리를 확인합니다."""
    command = ['find', '/', '(', '-nouser', '-o', '-nogroup', ')']
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
    return len(result.stdout.splitlines())

def check_files_in_dev():
    """/dev 디렉터리 내의 일반 파일을 확인합니다."""
    command = ['find', '/dev', '-type', 'f']
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
    return len(result.stdout.splitlines())

def check_home_directories():
    """홈 디렉터리가 적절히 설정되지 않은 계정을 확인합니다."""
    with open("/etc/passwd", "r") as passwd_file:
        lines = passwd_file.readlines()
    
    homedirectory_null_count = sum(1 for line in lines if line.split(":")[6].strip() not in ["/bin/false", "/sbin/nologin"] and line.split(":")[5] == "")
    homedirectory_slash_count = sum(1 for line in lines if line.split(":")[6].strip() not in ["/bin/false", "/sbin/nologin"] and line.split(":")[0] != "root" and line.split(":")[5] == "/")
    
    return homedirectory_null_count, homedirectory_slash_count

def main():
    bar()
    print("[SRV-095] 존재하지 않는 소유자 및 그룹 권한을 가진 파일 또는 디렉터리 존재")
    bar()
    
    with open(tmp1, 'w') as file:
        if check_files_without_owner_or_group() > 0:
            file.write("WARN: 소유자가 존재하지 않는 파일 및 디렉터리가 존재합니다.\n")
        else:
            file.write("OK: ※ U-06 결과 : 양호(Good)\n")
        
        if check_files_in_dev() > 0:
            file.write("WARN: /dev 디렉터리에 존재하지 않는 device 파일이 존재합니다.\n")
        else:
            file.write("OK: ※ U-16 결과 : 양호(Good)\n")
        
        homedirectory_null_count, homedirectory_slash_count = check_home_directories()
        if homedirectory_null_count > 0:
            file.write("WARN: 홈 디렉터리가 존재하지 않는 계정이 있습니다.\n")
        elif homedirectory_slash_count > 0:
            file.write("WARN: 관리자 계정(root)이 아닌데 홈 디렉터리가 '/'로 설정된 계정이 있습니다.\n")
        else:
            file.write("OK: ※ U-58 결과 : 양호(Good)\n")

if __name__ == "__main__":
    main()
