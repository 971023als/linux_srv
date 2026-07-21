import os

def check_hidden_files_and_dirs():
    hidden_files = []
    hidden_dirs = []

    for root, dirs, files in os.walk("/"):
        for name in files:
            if name.startswith("."):
                hidden_files.append(os.path.join(root, name))
        for name in dirs:
            if name.startswith("."):
                hidden_dirs.append(os.path.join(root, name))

    if hidden_files or hidden_dirs:
        print("WARN: 다음의 불필요한 숨김 파일 또는 디렉터리가 존재합니다:")
        for file in hidden_files:
            print(f"파일: {file}")
        for dir in hidden_dirs:
            print(f"디렉터리: {dir}")
    else:
        print("OK: 불필요한 숨김 파일 또는 디렉터리가 존재하지 않습니다.")

if __name__ == "__main__":
    check_hidden_files_and_dirs()
