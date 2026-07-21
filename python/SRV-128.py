import subprocess

# 결과 파일 초기화
script_name = "SCRIPTNAME.log"  # 실제 스크립트 이름으로 변경해야 합니다.

def write_result(message):
    with open(script_name, 'a') as f:
        f.write(message + "\n")

def check_ntfs_usage():
    try:
        output = subprocess.check_output(['mount'], text=True)
        if 'type ntfs' in output:
            ntfs_mounts = [line for line in output.splitlines() if 'type ntfs' in line]
            ntfs_info = '\n'.join(ntfs_mounts)
            write_result(f"WARN: NTFS 파일 시스템이 사용되고 있습니다:\n{ntfs_info}")
        else:
            write_result("OK: NTFS 파일 시스템이 사용되지 않습니다.")
    except subprocess.CalledProcessError as e:
        write_result(f"ERROR: 파일 시스템 확인 중 오류가 발생했습니다: {e}")

def main():
    open(script_name, 'w').close()  # 결과 파일 초기화
    check_ntfs_usage()

if __name__ == "__main__":
    main()
