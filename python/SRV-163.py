import os

def check_system_login_notices():
    motd_file = "/etc/motd"
    issue_file = "/etc/issue"

    # /etc/motd 파일 확인
    if os.path.isfile(motd_file) and os.path.getsize(motd_file) > 0:
        print("OK: /etc/motd 파일이 존재하며 내용이 있습니다.")
    else:
        print("WARN: /etc/motd 파일이 존재하지 않거나 비어 있습니다.")

    # /etc/issue 파일 확인
    if os.path.isfile(issue_file) and os.path.getsize(issue_file) > 0:
        print("OK: /etc/issue 파일이 존재하며 내용이 있습니다.")
    else:
        print("WARN: /etc/issue 파일이 존재하지 않거나 비어 있습니다.")

if __name__ == "__main__":
    check_system_login_notices()
