import re
import os

def check_smtp_service_info_exposure():
    postfix_config = "/etc/postfix/main.cf"
    sendmail_config = "/etc/mail/sendmail.cf"

    # Postfix 설정 검사
    if os.path.isfile(postfix_config):
        with open(postfix_config, 'r') as file:
            content = file.read()
            if re.search(r'^smtpd_banner = \$myhostname', content, re.MULTILINE):
                print("OK: Postfix에서 버전 정보 노출이 제한됩니다.")
            else:
                print("WARN: Postfix에서 버전 정보가 노출됩니다.")
    else:
        print("INFO: Postfix 서버 설정 파일이 존재하지 않습니다.")

    # Sendmail 설정 검사
    if os.path.isfile(sendmail_config):
        with open(sendmail_config, 'r') as file:
            content = file.read()
            if re.search(r'O SmtpGreetingMessage=\$j', content, re.MULTILINE):
                print("OK: Sendmail에서 버전 정보 노출이 제한됩니다.")
            else:
                print("WARN: Sendmail에서 버전 정보가 노출됩니다.")
    else:
        print("INFO: Sendmail 서버 설정 파일이 존재하지 않습니다.")

if __name__ == "__main__":
    check_smtp_service_info_exposure()
