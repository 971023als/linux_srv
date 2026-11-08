//! SRV-092 (사용자 홈 디렉터리 설정 점검) Rust 시범 포팅.
//!
//! 원본: linux_srv/python/SRV-092.py (유지됨, 이 포팅이 대체하지 않음)
//!
//! 목표: 원본과 동일한 stdout 문구/순서와 SRV-092.log 생성 동작.
//! 표준 라이브러리만 사용하며 외부 크레이트는 없다.
//!
//! 알려진 동등성 한계 (빌드/실행 비교 미수행, 코드 검토 수준):
//! - 오류 경로 출력이 다르다. Python은 traceback을 출력하고 종료하지만,
//!   이 포팅은 오류 메시지를 stderr에 출력하고 종료 코드 1로 끝낸다.
//! - Python의 open()은 로케일 인코딩(또는 UTF-8 모드)으로 디코딩하지만
//!   read_to_string은 UTF-8만 허용한다. 따라서 UTF-8이 아닌 내용이 있을 때
//!   Python은 로케일 인코딩으로 디코딩에 성공할 수 있는 반면 이 포팅은
//!   오류로 종료한다. 어느 쪽이 실패하는지는 Python의 로케일/UTF-8 모드와
//!   파일 내용에 따라 달라진다.
//! - Python의 print는 로케일 인코딩으로 stdout을 내보낸다. ASCII 로케일에서는
//!   한국어 출력이 UnicodeEncodeError로 실패할 수 있으나, 이 포팅은 항상
//!   UTF-8 바이트로 출력한다.
//! - Python의 str.strip()과 Rust의 trim()은 공백 문자 집합이 미세하게 다르다.
//! - Path::is_dir은 os.path.isdir과 같은 의도(심볼릭 링크 추적, 오류 시 false)로
//!   사용했으나, 모든 파일시스템 오류 경로에서의 동일성은 검증되지 않았다.

use std::fs::{self, File};
use std::path::Path;
use std::process;

const SCRIPT_NAME: &str = "SRV-092";

// 원본 result_msg와 동일한 문자열 (끝의 \n 포함).
// Python의 print(result_msg)는 여기에 \n을 하나 더 붙여 출력한다.
const RESULT_MSG: &str = "[양호]: 모든 사용자의 홈 디렉터리가 적절히 설정되어 있는 경우\n[취약]: 하나 이상의 사용자의 홈 디렉터리가 적절히 설정되지 않은 경우\n";

fn bar() {
    // 원본: print("-" * 40)
    println!("----------------------------------------");
}

fn check_home_directories(passwd_contents: &str) {
    // 원본: /etc/passwd를 행 단위로 읽어 strip().split(':') 후 필드 6개 이상만 처리
    for line in passwd_contents.lines() {
        let parts: Vec<&str> = line.trim().split(':').collect();
        if parts.len() >= 6 {
            let user = parts[0];
            let home_dir = parts[5];
            // 원본: not os.path.isdir(home_dir) or not home_dir
            if !Path::new(home_dir).is_dir() || home_dir.is_empty() {
                println!(
                    "WARN: 사용자 {} 에 대한 홈 디렉터리({})가 잘못 설정되었습니다.",
                    user, home_dir
                );
            } else {
                println!(
                    "OK: 사용자 {} 의 홈 디렉터리({})가 적절히 설정되었습니다.",
                    user, home_dir
                );
            }
        }
    }
}

fn main() {
    // 원본 모듈 최상단과 같은 순서로, 먼저 CWD에 SRV-092.log를 생성/초기화한다.
    // (원본도 내용을 기록하지 않고 빈 파일로 남긴다)
    let log_name = format!("{}.log", SCRIPT_NAME);
    if let Err(e) = File::create(&log_name) {
        // Python도 open() 실패 시 예외로 종료한다. 출력 형태만 다르다.
        eprintln!("{}: {}", log_name, e);
        process::exit(1);
    }

    bar();
    println!("[SRV-092] 사용자 홈 디렉터리 설정 미흡");
    bar();

    // 원본은 check_home_directories() 안에서 /etc/passwd를 연다.
    // 읽기 실패 시 Python은 traceback으로 종료하므로, 여기서도 오류 후 종료한다.
    let passwd_contents = match fs::read_to_string("/etc/passwd") {
        Ok(contents) => contents,
        Err(e) => {
            eprintln!("/etc/passwd: {}", e);
            process::exit(1);
        }
    };

    check_home_directories(&passwd_contents);

    // 원본: print(result_msg) — result_msg 끝의 \n에 print의 \n이 더해진다.
    println!("{}", RESULT_MSG);
}
