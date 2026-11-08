//! SRV-096 (사용자 환경파일의 소유자 또는 권한 설정 점검) Rust 시범 포팅.
//!
//! 원본: linux_srv/python/SRV-096.py (유지됨, 이 포팅이 대체하지 않음)
//!
//! 목표: 원본과 동일한 SRV-096.log 내용/기록 순서와 최종 stdout 출력
//! (로그 전체 덤프 + print의 추가 개행). 표준 라이브러리만 사용하며
//! 외부 크레이트는 없다.
//!
//! 알려진 동등성 한계 (빌드/실행 비교 미수행, 코드 검토 수준):
//! - 계정 범위: Python의 pwd.getpwall()/getpwuid()는 NSS를 거치므로
//!   LDAP/NIS 등 외부 계정까지 포함될 수 있으나, 이 포팅은 /etc/passwd만
//!   읽는다. 따라서 NSS 환경에서는 점검 대상 사용자 집합과 파일 소유자
//!   이름 해석이 원본과 달라질 수 있다 (사용자에게 사전 고지된 제한).
//! - 소유자 uid가 /etc/passwd에 없으면: Python의 pwd.getpwuid는 KeyError로
//!   traceback 종료하지만, 이 포팅은 오류 메시지를 stderr에 출력하고
//!   종료 코드 1로 끝낸다.
//! - 그 외 오류 경로 출력이 다르다. Python은 traceback을 출력하고 종료하지만,
//!   이 포팅은 오류 메시지를 stderr에 출력하고 종료 코드 1로 끝낸다.
//! - Python의 open()은 로케일 인코딩(또는 UTF-8 모드)으로 로그를 쓰고
//!   읽지만, 이 포팅은 항상 UTF-8로 쓰고 읽는다. ASCII 로케일에서 Python의
//!   한국어 기록/출력이 실패할 수 있는 반면 이 포팅은 성공한다.
//! - 사용자 순회 순서: 원본은 getpwall() 반환 순서(dict 삽입 순서)를 따르고,
//!   이 포팅은 /etc/passwd 행 순서를 따른다. 파일 기반 NSS에서는 일반적으로
//!   같으나 검증되지 않았다. 중복 사용자명은 원본 dict와 같이 마지막 값이
//!   이기되 위치는 첫 삽입 위치를 유지하도록 했다.
//! - os.path.isfile/os.stat(심볼릭 링크 추적)과 Path::is_file/fs::metadata는
//!   같은 의도로 사용했으나, 모든 파일시스템 오류 경로에서의 동일성은
//!   검증되지 않았다.
//! - 원본의 for/else 구조(파일 하나라도 부적절이면 WARN 후 다음 사용자로,
//!   전부 통과 시 OK)를 그대로 재현했다.

use std::fs::{self, File, OpenOptions};
use std::io::Write;
use std::os::unix::fs::{MetadataExt, PermissionsExt};
use std::path::Path;
use std::process;

const SCRIPT_NAME: &str = "SRV-096";
const PASSWD_PATH: &str = "/etc/passwd";

// 원본이 로그에 기록하는 헤더와 바이트 단위로 동일한 문자열.
const HEADER: &str = "CODE [SRV-096] 사용자 환경파일의 소유자 또는 권한 설정 미흡\n\n[양호]: 사용자 환경 파일의 소유자가 해당 사용자이고, 권한이 적절하게 설정된 경우\n[취약]: 사용자 환경 파일의 소유자가 해당 사용자가 아니거나, 권한이 부적절하게 설정된 경우\n\n------------------------------------------------------------\n";

// 원본 start_files 리스트와 동일한 7개.
const START_FILES: [&str; 7] = [
    ".profile",
    ".cshrc",
    ".login",
    ".kshrc",
    ".bash_profile",
    ".bashrc",
    ".bash_login",
];

struct PasswdEntry {
    name: String,
    uid: u32,
    dir: String,
    shell: String,
}

// /etc/passwd 파싱. 필드가 7개 미만인 행은 건너뛴다
// (원본의 getpwall은 libc 파서를 쓰므로 malformed 행 처리는 다를 수 있음).
fn parse_passwd(contents: &str) -> Vec<PasswdEntry> {
    let mut entries = Vec::new();
    for line in contents.lines() {
        let parts: Vec<&str> = line.split(':').collect();
        if parts.len() >= 7 {
            if let Ok(uid) = parts[2].parse::<u32>() {
                entries.push(PasswdEntry {
                    name: parts[0].to_string(),
                    uid,
                    dir: parts[5].to_string(),
                    shell: parts[6].to_string(),
                });
            }
        }
    }
    entries
}

fn append_log(log_path: &str, line: &str) {
    // 원본의 warn()/ok()와 같이 매번 append 모드로 열어 한 줄 기록 후 닫는다.
    let mut f = match OpenOptions::new().append(true).open(log_path) {
        Ok(f) => f,
        Err(e) => {
            eprintln!("{}: {}", log_path, e);
            process::exit(1);
        }
    };
    if let Err(e) = f.write_all(line.as_bytes()) {
        eprintln!("{}: {}", log_path, e);
        process::exit(1);
    }
}

fn main() {
    let log_name = format!("{}.log", SCRIPT_NAME);

    // 원본 모듈 최상단: 로그 파일을 생성/초기화하고 헤더를 기록한다.
    // (실패 시 Python은 traceback, 이 포팅은 stderr + exit 1)
    let mut f = match File::create(&log_name) {
        Ok(f) => f,
        Err(e) => {
            eprintln!("{}: {}", log_name, e);
            process::exit(1);
        }
    };
    if let Err(e) = f.write_all(HEADER.as_bytes()) {
        eprintln!("{}: {}", log_name, e);
        process::exit(1);
    }
    drop(f);

    // 원본 extract_user_homedirectory_info():
    // shell이 /bin/false, /sbin/nologin이 아니고 홈 디렉터리가 비어 있지 않은
    // 사용자만 {이름: 홈} 으로 수집. 중복 이름은 마지막 값이 이기되 위치는
    // 첫 삽입 위치 유지 (Python dict와 동일).
    let passwd_contents = match fs::read_to_string(PASSWD_PATH) {
        Ok(c) => c,
        Err(e) => {
            eprintln!("{}: {}", PASSWD_PATH, e);
            process::exit(1);
        }
    };
    let entries = parse_passwd(&passwd_contents);

    let mut users: Vec<(String, String)> = Vec::new();
    for e in &entries {
        if e.shell != "/bin/false" && e.shell != "/sbin/nologin" && !e.dir.is_empty() {
            if let Some(existing) = users.iter_mut().find(|(n, _)| *n == e.name) {
                existing.1 = e.dir.clone();
            } else {
                users.push((e.name.clone(), e.dir.clone()));
            }
        }
    }

    // uid -> 이름 맵 (원본의 pwd.getpwuid 대체, /etc/passwd 기준)
    let owner_name = |uid: u32| -> Option<&str> {
        entries.iter().find(|e| e.uid == uid).map(|e| e.name.as_str())
    };

    // 원본 check_user_environment_files(): for/else 구조 그대로.
    for (user, homedir) in &users {
        let mut warned = false;
        for filename in START_FILES {
            let filepath = Path::new(homedir).join(filename);
            if filepath.is_file() {
                let stat_info = match fs::metadata(&filepath) {
                    Ok(m) => m,
                    Err(e) => {
                        eprintln!("{}: {}", filepath.display(), e);
                        process::exit(1);
                    }
                };
                let file_owner = match owner_name(stat_info.uid()) {
                    Some(n) => n.to_string(),
                    None => {
                        // Python의 pwd.getpwuid도 없는 uid면 KeyError로 종료한다.
                        eprintln!("uid {}: no such user in {}", stat_info.uid(), PASSWD_PATH);
                        process::exit(1);
                    }
                };
                if (file_owner != *user && file_owner != "root")
                    || (stat_info.permissions().mode() & 0o002) != 0
                {
                    append_log(
                        &log_name,
                        &format!(
                            "WARN: {} 홈 디렉터리 내 {} 환경 변수 파일의 설정이 적절하지 않습니다.\n",
                            homedir, filename
                        ),
                    );
                    warned = true;
                    break;
                }
            }
        }
        if !warned {
            append_log(
                &log_name,
                &format!(
                    "OK: {} 홈 디렉터리 내 검사된 모든 시작 파일이 적절한 소유자를 가지며, 다른 사용자(other)의 쓰기(w) 권한이 없습니다.\n",
                    homedir
                ),
            );
        }
    }

    // 원본 모듈 말미: 로그 전체를 읽어 print(f.read())로 출력한다.
    // 내용 끝의 \n에 print의 \n이 더해진다.
    let log_contents = match fs::read_to_string(&log_name) {
        Ok(c) => c,
        Err(e) => {
            eprintln!("{}: {}", log_name, e);
            process::exit(1);
        }
    };
    println!("{}", log_contents);
}
