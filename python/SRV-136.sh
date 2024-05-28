import os
import stat

# 결과 파일 초기화
script_name = "SCRIPTNAME.log"  # 실제 스크립트 이름으로 변경해야 합니다.

def write_result(message):
    with open(script_name, 'a') as f:
        f.write(message + "\n")

def check_shutdown_command():
    shutdown_command = "/sbin/shutdown"

    # shutdown 명령의 존재 여부 확인
    if not os.path.exists(shutdown_command):
        write_result("WARN: shutdown 명령이 시스템에 존재하지 않습니다.")
        return

    # shutdown 명령의 실행 가능 여부 확인
    if not os.access(shutdown_command, os.X_OK):
        write_result("WARN: shutdown 명령이 실행 가능하지 않습니다.")
    else:
        write_result("OK: shutdown 명령이 실행 가능합니다.")

    # shutdown 명령에 대한 권한 확인
    permissions = oct(os.stat(shutdown_command).st_mode)[-3:]
    if permissions[2] != '1' and permissions[2] != '5':  # 실행 권한이 없는 경우
        write_result("WARN: shutdown 명령에 적절한 실행 권한이 설정되지 않았습니다.")
    else:
        write_result("OK: shutdown 명령에 적절한 실행 권한이 설정되어 있습니다.")

def main():
    open(script_name, 'w').close()  # 결과 파일 초기화
    check_shutdown_command()

if __name__ == "__main__":
    main()
