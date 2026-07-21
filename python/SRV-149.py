import subprocess

def check_encrypted_volumes():
    # lsblk 명령을 실행하여 디스크 볼륨 정보를 가져옵니다.
    command = ['lsblk', '-o', 'NAME,TYPE,MOUNTPOINT,SIZE,STATE']
    result = subprocess.run(command, capture_output=True, text=True)
    
    # 'crypt' 타입으로 마운트된 볼륨을 찾습니다.
    encrypted_volumes = [line for line in result.stdout.splitlines() if 'crypt' in line]
    
    # 암호화된 볼륨의 존재 여부에 따라 결과를 출력합니다.
    if encrypted_volumes:
        print("OK: 다음의 암호화된 디스크 볼륨이 존재합니다:")
        for volume in encrypted_volumes:
            print(volume)
    else:
        print("WARN: 암호화된 디스크 볼륨이 존재하지 않습니다.")

if __name__ == "__main__":
    check_encrypted_volumes()
