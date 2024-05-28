import os
import subprocess

# 파일 이름 설정 및 초기화
script_name = "SCRIPTNAME"  # 실제 스크립트 이름으로 변경해야 합니다.
tmp1 = f"{script_name}.log"

# 로그 파일 초기화
with open(tmp1, 'w') as file:
    pass

def bar():
    print("-" * 40)

def find_files_with_bit(bit):
    """특정 비트가 설정된 파일을 찾습니다."""
    try:
        # find 명령어 실행
        result = subprocess.check_output(['find', '/', f'-perm', f'/{bit}', '-type', 'f'], stderr=subprocess.DEVNULL).decode('utf-8')
        return result.strip().split('\n') if result else []
    except subprocess.CalledProcessError as e:
        print(f"Error finding files: {e}")
        return []

def check_files(files, bit_description):
    """파일 목록을 확인하고 메시지를 출력합니다."""
    if files:
        print(f"WARN: {bit_description} 비트가 설정된 불필요한 파일이 있습니다:", ', '.join(files))
    else:
        print(f"OK: {bit_description} 비트가 설정된 불필요한 파일이 없습니다.")

def main():
    bar()

    # SUID 및 SGID 비트 설명
    print("[U-91] 불필요하게 SUID, SGID bit가 설정된 파일 존재")
    
    # 결과 메시지 초기화
    result_msg = "[양호]: SUID 및 SGID 비트가 필요하지 않은 파일에 설정되지 않은 경우\n[취약]: SUID 및 SGID 비트가 필요하지 않은 파일에 설정된 경우\n"
    bar()
    
    # SUID 및 SGID 비트가 설정된 파일 검색
    suid_files = find_files_with_bit('4000')
    sgid_files = find_files_with_bit('2000')

    # 파일 확인 및 메시지 출력
    check_files(suid_files, "SUID")
    check_files(sgid_files, "SGID")

    # 결과 메시지 출력
    print(result_msg)

if __name__ == "__main__":
    main()
