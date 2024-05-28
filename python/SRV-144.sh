import os
import subprocess

def check_unnecessary_files_in_dev():
    try:
        # /dev 디렉터리 내 파일 타입이 'file'인 항목을 찾습니다.
        result = subprocess.check_output("find /dev -type f", shell=True, text=True)
        if result.strip():
            print("WARN: /dev 디렉터리에 존재하지 않는 device 파일이 존재합니다.")
            print("불필요한 파일 목록:")
            print(result)
        else:
            print("OK: /dev 경로에 불필요한 파일이 존재하지 않습니다.")
    except subprocess.CalledProcessError as e:
        print(f"Error checking for unnecessary files in /dev: {e}")

if __name__ == "__main__":
    check_unnecessary_files_in_dev()
