import re

# 로그 파일 초기화 및 메시지 기록 함수
log_file_path = "password_storage_method_check.log"

def log_message(message):
    with open(log_file_path, "a") as log_file:
        log_file.write(message + "\n")

# 패스워드 저장 방식 검사
def check_password_storage():
    pam_file = "/etc/pam.d/common-password"
    try:
        with open(pam_file, "r") as file:
            content = file.read()
            if re.search(r"md5|des", content):
                log_message("취약한 패스워드 해싱 알고리즘이 사용 중입니다: {}".format(pam_file))
            else:
                log_message("강력한 패스워드 해싱 알고리즘이 사용 중입니다: {}".format(pam_file))
    except FileNotFoundError:
        log_message("파일을 찾을 수 없습니다: {}".format(pam_file))

# 실행
check_password_storage()

# 결과 출력
with open(log_file_path, "r") as log_file:
    print(log_file.read())
