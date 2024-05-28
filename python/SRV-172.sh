import subprocess

def check_nfs_shares():
    try:
        nfs_shares = subprocess.check_output(['showmount', '-e', 'localhost'], text=True)
        if nfs_shares.strip():
            print("WARN: NFS에서 다음 공유가 발견되었습니다:\n", nfs_shares)
        else:
            print("OK: NFS에서 불필요한 공유가 존재하지 않습니다.")
    except Exception as e:
        print("ERROR: NFS 공유 확인 중 오류가 발생했습니다.", str(e))

def check_samba_shares():
    try:
        samba_shares = subprocess.check_output(['smbstatus', '-S'], text=True)
        if samba_shares.strip():
            print("WARN: Samba에서 다음 공유가 발견되었습니다:\n", samba_shares)
        else:
            print("OK: Samba에서 불필요한 공유가 존재하지 않습니다.")
    except Exception as e:
        print("ERROR: Samba 공유 확인 중 오류가 발생했습니다.", str(e))

if __name__ == "__main__":
    check_nfs_shares()
    check_samba_shares()
