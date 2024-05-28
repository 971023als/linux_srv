import subprocess

def check_duplicate_uids():
    try:
        # /etc/passwd 파일에서 UID(3번째 필드)를 추출하여 정렬하고, 중복된 항목을 찾습니다.
        result = subprocess.check_output("awk -F ':' '{print $3}' /etc/passwd | sort | uniq -d", shell=True, text=True)
        if result.strip():
            print("WARN: 동일한 UID로 설정된 사용자 계정이 존재합니다.")
            print(f"중복 UID: {result.strip()}")
        else:
            print("OK: 중복 UID가 부여된 계정이 존재하지 않습니다.")
    except subprocess.CalledProcessError as e:
        print(f"Error checking for duplicate UIDs: {e}")

if __name__ == "__main__":
    check_duplicate_uids()
