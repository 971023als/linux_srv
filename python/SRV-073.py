import grp

# 로그 파일 초기화 및 메시지 기록 함수
log_file_path = "admin_group_check.log"

def log_message(message):
    with open(log_file_path, "a") as log_file:
        log_file.write(message + "\n")

# 관리자 그룹의 불필요한 사용자 존재 여부 검사
def check_unnecessary_users_in_admin_group(group_name, unwanted_user):
    try:
        group_info = grp.getgrnam(group_name)
        if unwanted_user in group_info.gr_mem:
            log_message(f"관리자 그룹({group_name})에 불필요한 사용자({unwanted_user})가 포함되어 있습니다.")
        else:
            log_message(f"관리자 그룹({group_name})에 불필요한 사용자가 없습니다.")
    except KeyError:
        log_message(f"지정된 그룹({group_name})이 시스템에 존재하지 않습니다.")

# 실행
check_unnecessary_users_in_admin_group("sudo", "testuser")

# 결과 출력
with open(log_file_path, "r") as log_file:
    print(log_file.read())
