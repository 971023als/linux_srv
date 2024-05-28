def check_unnecessary_shell_accounts():
    with open("/etc/passwd", "r") as passwd_file:
        accounts = passwd_file.readlines()

    unnecessary_shells = ["/bin/false", "/sbin/nologin"]
    warning_accounts = []

    for account in accounts:
        fields = account.strip().split(":")
        if fields[0] in ["daemon", "bin", "sys", "adm", "listen", "nobody", "nobody4", "noaccess", "diag", "operator", "gopher", "games", "ftp", "apache", "httpd", "www-data", "mysql", "mariadb", "postgres", "mail", "postfix", "news", "lp", "uucp", "nuucp"] and fields[-1] not in unnecessary_shells:
            warning_accounts.append(account)

    if warning_accounts:
        print("WARN: 로그인이 필요하지 않은 불필요한 계정에 /bin/false 또는 /sbin/nologin 쉘이 부여되지 않았습니다.")
        for account in warning_accounts:
            print(account.strip())
    else:
        print("OK: 불필요하게 Shell이 부여된 계정이 존재하지 않습니다.")

if __name__ == "__main__":
    check_unnecessary_shell_accounts()
