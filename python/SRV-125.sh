import subprocess

# 결과 파일 초기화
script_name = "SCRIPTNAME.log"  # 실제 스크립트 이름으로 변경해야 합니다.

def write_result(message):
    with open(script_name, 'a') as f:
        f.write(message + "\n")

def check_gsettings(schema, key):
    try:
        output = subprocess.check_output(['gsettings', 'get', schema, key], text=True).strip()
        return output == 'true'
    except subprocess.CalledProcessError:
        return False

def check_qdbus(interface, path, method):
    try:
        output = subprocess.check_output(['qdbus', interface, path, method], text=True).strip()
        return output.lower() == 'true'
    except subprocess.CalledProcessError:
        return False

def check_xfconf_query(channel, property):
    try:
        output = subprocess.check_output(['xfconf-query', '-c', channel, '-p', property], text=True).strip()
        return output.lower() == 'true'
    except subprocess.CalledProcessError:
        return False

def main():
    open(script_name, 'w').close()  # 결과 파일 초기화
    
    # GNOME
    if check_gsettings('org.gnome.desktop.screensaver', 'lock-enabled'):
        write_result("OK: GNOME에서 화면보호기가 설정되어 있습니다.")
    else:
        write_result("WARN: GNOME에서 화면보호기가 설정되어 있지 않습니다.")
    
    # KDE Plasma
    if check_qdbus('org.freedesktop.ScreenSaver', '/ScreenSaver', 'org.freedesktop.ScreenSaver.GetActive'):
        write_result("OK: KDE에서 화면보호기가 설정되어 있습니다.")
    else:
        write_result("WARN: KDE에서 화면보호기가 설정되어 있지 않습니다.")
    
    # Xfce
    if check_xfconf_query('xfce4-screensaver', '/saver/enabled'):
        write_result("OK: Xfce에서 화면보호기가 설정되어 있습니다.")
    else:
        write_result("WARN: Xfce에서 화면보호기가 설정되어 있지 않습니다.")
    
    # Cinnamon
    if check_gsettings('org.cinnamon.desktop.screensaver', 'lock-enabled'):
        write_result("OK: Cinnamon에서 화면보호기가 설정되어 있습니다.")
    else:
        write_result("WARN: Cinnamon에서 화면보호기가 설정되어 있지 않습니다.")

if __name__ == "__main__":
    main()
