import os

# 결과 파일 초기화 및 기본 정보 추가
script_name = "SCRIPTNAME"  # 실제 스크립트 이름으로 변경해야 합니다.
tmp1 = f"{script_name}.log"

with open(tmp1, 'w') as f:
    f.write("CODE [SRV-115] 로그의 정기적 검토 및 보고 미수행\n\n")
    f.write("[양호]: 로그가 정기적으로 검토 및 보고되고 있는 경우\n")
    f.write("[취약]: 로그가 정기적으로 검토 및 보고되지 않는 경우\n")
    f.write("\n------------------------------------------------------------\n")

def check_file_existence(path, message):
    if not os.path.isfile(path):
        with open(tmp1, 'a') as f:
            f.write(f"WARN: {message}가 존재하지 않습니다.\n")
    else:
        with open(tmp1, 'a') as f:
            f.write(f"OK: {message}가 존재합니다.\n")

def main():
    # 로그 검토 및 보고 스크립트 존재 여부 확인
    log_review_script = "/path/to/log/review/script"
    check_file_existence(log_review_script, "로그 검토 및 보고 스크립트")
    
    # 로그 보고서 존재 여부 확인
    log_report = "/path/to/log/report"
    check_file_existence(log_report, "로그 보고서")

if __name__ == "__main__":
    main()
