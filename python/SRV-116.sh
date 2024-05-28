import re

# 결과 파일 초기화 및 기본 정보 추가
script_name = "SCRIPTNAME.log"  # 실제 스크립트 이름으로 변경해야 합니다.

def write_result(message):
    with open(script_name, 'a') as f:
        f.write(message + "\n")

def check_audit_settings():
    auditd_conf_path = "/etc/audit/auditd.conf"
    try:
        with open(auditd_conf_path, 'r') as file:
            contents = file.read()
            
        # 설정 확인
        space_left_action = re.search(r'^\s*space_left_action\s*=\s*(\S+)', contents, re.M|re.I)
        action_mail_acct = re.search(r'^\s*action_mail_acct\s*=\s*(\S+)', contents, re.M|re.I)
        admin_space_left_action = re.search(r'^\s*admin_space_left_action\s*=\s*(\S+)', contents, re.M|re.I)

        if space_left_action and "email" in space_left_action.group(1):
            if action_mail_acct and "root" in action_mail_acct.group(1) and admin_space_left_action and "halt" in admin_space_left_action.group(1):
                write_result("OK: 보안 감사 실패 시 시스템이 즉시 종료되도록 설정됨")
            else:
                write_result("WARN: 보안 감사 실패 시 시스템이 즉시 종료되지 않도록 설정됨")
        else:
            write_result("WARN: 보안 감사 실패 시 이메일 알림이 설정되지 않음")
    except FileNotFoundError:
        write_result(f"WARN: {auditd_conf_path} 파일이 존재하지 않습니다.")

def main():
    # 결과 파일 초기화
    open(script_name, 'w').close()
    check_audit_settings()

if __name__ == "__main__":
    main()
