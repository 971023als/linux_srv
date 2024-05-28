import pwd
import grp

# 로그 파일 초기화 및 메시지 기록 함수
log_file_path = "account_check.log"

def log_message(message):
    with open(log_file_path, "a") as log_file:
        log_file.write(message + "\n")

# 불필요하거나 관리되지 않는 계정 검사
def check_unnecessary_accounts():
    unnecessary_accounts = ['daemon', 'bin', 'sys', 'adm', 'listen', 'nobody', 'nobody4', 'noaccess', 'diag', 'operator', 'gopher', 'games', 'ftp', 'apache', 'httpd', 'www-data', 'mysql', 'mariadb', 'postgres', 'mail', 'postfix', 'news', 'lp', 'uucp', 'nuucp']
    found_unnecessary_accounts = False

    for user in pwd.getpwall():
        if user.pw_name in unnecessary_accounts:
            log_message(f"불필요한 계정이 존재합니다: {user.pw_name}")
            found_unnecessary_accounts = True
            break

    if not found_unnecessary_accounts:
        log_message("※ U-49 결과 : 양호(Good)")

    # 관리자 그룹에 불필요한 계정이 등록되어 있는지 검사
    try:
        root_group_members = grp.getgrnam("root").gr_mem
        for account in unnecessary_accounts:
            if account in root_group_members:
                log_message(f"관리자 그룹(root)에 불필요한 계정이 등록되어 있습니다: {account}")
                found_unnecessary_accounts = True
                break

        if not found_unnecessary_accounts:
            log_message("※ U-50 결과 : 양호(Good)")
    except KeyError:
        log_message("root 그룹이 존재하지 않습니다.")

# 실행
check_unnecessary_accounts()

# 결과 출력
with open(log_file_path, "r") as log_file:
    print(log_file.read())
