import os
import subprocess
import re

def bar():
    print("=" * 40)

def check_accounts():
    # Path to the temporary log file
    tmp1 = "scriptname.log"
    with open(tmp1, "w") as log_file:
        bar()

        # Code for checking unnecessary guest accounts activation
        result = """
[양호]: 불필요한 Guest 계정이 비활성화 되어 있는 경우
[취약]: 불필요한 Guest 계정이 활성화 되어 있는 경우
"""
        print(result)
        bar()

        # Check if /etc/passwd exists
        if os.path.exists("/etc/passwd"):
            with open("/etc/passwd", "r") as passwd_file:
                passwd_content = passwd_file.read()
                # Regular expression pattern for unnecessary accounts
                pattern = r'\b(daemon|bin|sys|adm|listen|nobody|nobody4|noaccess|diag|operator|gopher|games|ftp|apache|httpd|www-data|mysql|mariadb|postgres|mail|postfix|news|lp|uucp|nuucp)\b'
                if len(re.findall(pattern, passwd_content)) > 0:
                    log_file.write("불필요한 계정이 존재합니다.\n")
                    return
            log_file.write("※ U-49 결과 : 양호(Good)\n")

        # Check if /etc/group exists
        if os.path.exists("/etc/group"):
            with open("/etc/group", "r") as group_file:
                group_content = group_file.read()
                if len(re.findall(pattern, group_content)) > 0:
                    log_file.write("관리자 그룹(root)에 불필요한 계정이 등록되어 있습니다.\n")
                    return
            log_file.write("※ U-50 결과 : 양호(Good)\n")

        print(open(tmp1).read())

# Execute the function
check_accounts()
