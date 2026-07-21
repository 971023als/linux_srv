def check_unnecessary_groups():
    with open("/etc/group", "r") as group_file:
        groups = group_file.readlines()

    with open("/etc/passwd", "r") as passwd_file:
        passwd = passwd_file.readlines()

    group_ids = {line.split(":")[2] for line in groups if line.split(":")[3].strip() == ''}
    user_gids = {line.split(":")[3].strip() for line in passwd}

    unnecessary_gids = group_ids - user_gids

    if unnecessary_gids:
        print("WARN: 불필요한 그룹이 존재합니다:", ', '.join(unnecessary_gids))
    else:
        print("OK: 불필요한 그룹이 존재하지 않습니다.")

if __name__ == "__main__":
    check_unnecessary_groups()
