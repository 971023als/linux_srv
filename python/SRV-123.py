import os

# 결과 파일 초기화
script_name = "SCRIPTNAME.log"  # 실제 스크립트 이름으로 변경해야 합니다.

def write_result(message):
    with open(script_name, 'a') as f:
        f.write(message + "\n")

def check_last_login_exposure():
    files = ["/etc/motd", "/etc/issue", "/etc/issue.net"]
    for file in files:
        if os.path.isfile(file):
            with open(file, 'r') as f:
                contents = f.read()
            if 'Last login' in contents:
                write_result(f"WARN: 파일 {file} 에 최종 로그인 사용자 정보가 포함되어 있습니다.")
            else:
                write_result(f"OK: 파일 {file} 에 최종 로그인 사용자 정보가 포함되지 않았습니다.")
        else:
            write_result(f"INFO: 파일 {file} 이(가) 존재하지 않습니다.")

def main():
    open(script_name, 'w').close()  # 결과 파일 초기화
    check_last_login_exposure()

if __name__ == "__main__":
    main()
