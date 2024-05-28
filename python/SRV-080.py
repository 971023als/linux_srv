import os

def bar():
    print("=" * 40)

def check_cups_config():
    tmp1 = "scriptname.log"
    with open(tmp1, "w") as result:
        bar()

        # Header for checking printer driver installation restrictions
        header = """
[양호]: 일반 사용자에 의한 프린터 드라이버 설치가 제한된 경우
[취약]: 일반 사용자에 의한 프린터 드라이버 설치에 제한이 없는 경우
"""
        result.write(header)
        bar()

        # Path to the CUPS configuration file
        cups_config_file = "/etc/cups/cupsd.conf"

        # Check if the CUPS configuration file exists
        if os.path.isfile(cups_config_file):
            with open(cups_config_file, "r") as file:
                system_group = None
                for line in file:
                    if line.startswith("SystemGroup"):
                        system_group = line.strip()
                        break
                
                if system_group:
                    message = f"CUPS 설정에서 시스템 그룹이 지정됨: {system_group}\n"
                    result.write(message)
                else:
                    warning_message = "CUPS 설정에서 시스템 그룹이 지정되지 않음\n"
                    result.write(warning_message)
        else:
            warning_message = f"CUPS 설정 파일({cups_config_file})이 존재하지 않습니다.\n"
            result.write(warning_message)

    # Read and print the content of the log file
    with open(tmp1, "r") as file:
        print(file.read())

# Execute the check
check_cups_config()
