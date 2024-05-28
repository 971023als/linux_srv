# 로그 파일 초기화 및 메시지 기록 함수
log_file_path = "administrator_account_check.log"

def log_message(message):
    with open(log_file_path, "a") as log_file:
        log_file.write(message + "\n")

# 'Administrator' 계정 존재 여부 검사
def check_administrator_account():
    try:
        with open("/etc/passwd", "r") as file:
            if "Administrator" in file.read():
                log_message("기본 'Administrator' 계정이 존재합니다.")
            else:
                log_message("기본 'Administrator' 계정이 존재하지 않습니다.")
    except FileNotFoundError:
        log_message("파일을 찾을 수 없습니다: /etc/passwd")

# 실행
check_administrator_account()

# 결과 출력
with open(log_file_path, "r") as log_file:
    print(log_file.read())
