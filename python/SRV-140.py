import subprocess

def check_gnome_media_handling():
    # dconf 경로 설정
    dconf_paths = {
        'automount': '/org/gnome/desktop/media-handling/automount',
        'automount_open': '/org/gnome/desktop/media-handling/automount-open',
    }

    # GNOME 환경 설정 확인
    results = {}
    for key, path in dconf_paths.items():
        try:
            result = subprocess.check_output(['dconf', 'read', path], text=True).strip()
            results[key] = result
        except subprocess.CalledProcessError:
            print(f"ERROR: Unable to read {path} setting.")
            return

    # 결과 출력
    if results.get('automount') == "'false'" and results.get('automount_open') == "'false'":
        print("OK: 이동식 미디어의 자동 마운트 및 열기가 비활성화되어 있습니다.")
    else:
        print("WARN: 이동식 미디어의 자동 마운트 또는 열기가 활성화되어 있습니다.")

def main():
    # dconf 도구 설치 및 GNOME 환경 확인
    try:
        subprocess.check_call(['dconf'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        check_gnome_media_handling()
    except subprocess.CalledProcessError:
        print("INFO: dconf 도구가 설치되어 있지 않거나 GNOME 환경이 아닙니다.")

if __name__ == "__main__":
    main()
