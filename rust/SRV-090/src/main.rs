//! SRV-090 (불필요한 원격 레지스트리 서비스 활성화 점검) Rust 시범 포팅.
//!
//! 원본: linux_srv/python/SRV-090.py (유지됨, 이 포팅이 대체하지 않음)
//!
//! 목표: 원본과 동일한 stdout 문구/순서와 빈 SRV-090.log 생성 동작.
//! 표준 라이브러리만 사용하며 외부 크레이트는 없다.
//!
//! 외부 명령 의존 보존 (사용자 승인 범위): 이 포팅은 원본과 같이
//! `systemctl is-active --quiet remote-registry`를 실행하며, 이를 제거하거나
//! 대체하지 않는다. 또한 원본의 한계인 "명령이 비0 종료로 실패하면 서비스
//! 비활성(양호)으로 판정"하는 동작을 그대로 보존한다.
//!
//! 알려진 동등성 한계 (빌드/실행 비교 미수행, 코드 검토 수준):
//! - systemctl 실행 파일 자체가 없으면: Python은 FileNotFoundError traceback으로
//!   종료하지만(원본도 미처리), 이 포팅은 오류 메시지를 stderr에 출력하고
//!   종료 코드 1로 끝낸다.
//! - 그 외 오류 경로 출력도 Python traceback 대신 stderr + exit 1이다.
//! - Python의 print는 로케일 인코딩으로 stdout을 내보낸다. ASCII 로케일에서는
//!   한국어 출력이 UnicodeEncodeError로 실패할 수 있으나, 이 포팅은 항상
//!   UTF-8 바이트로 출력한다.
//! - systemctl이 시그널로 종료된 경우 Python의 CalledProcessError(음수
//!   리턴코드)와 Rust의 status.success()==false는 둘 다 비활성 판정으로
//!   이어지나, 모든 종료 형태의 동일성은 실행 비교하지 않았다.

use std::fs::File;
use std::process::{self, Command};

const SCRIPT_NAME: &str = "SRV-090";
const SERVICE_NAME: &str = "remote-registry";

fn bar() {
    // 원본: print("-" * 40)
    println!("----------------------------------------");
}

fn check_remote_registry_service() -> bool {
    // 원본: subprocess.check_call(['systemctl','is-active','--quiet',SERVICE])
    // 성공(종료코드 0)이면 true, CalledProcessError(비0/시그널 종료)면 false.
    // --quiet이므로 명령 자체 출력은 없으며, stdio 상속도 원본과 동일하다.
    match Command::new("systemctl")
        .args(["is-active", "--quiet", SERVICE_NAME])
        .status()
    {
        Ok(status) => status.success(),
        Err(e) => {
            // Python도 systemctl이 없으면 FileNotFoundError로 종료한다.
            // 출력 형태만 다르다 (traceback vs stderr + exit 1).
            eprintln!("systemctl: {}", e);
            process::exit(1);
        }
    }
}

fn main() {
    // 원본 모듈 최상단과 같이, 먼저 CWD에 SRV-090.log를 생성/초기화한다.
    // (원본도 이후 아무것도 기록하지 않고 빈 파일로 남긴다)
    let log_name = format!("{}.log", SCRIPT_NAME);
    if let Err(e) = File::create(&log_name) {
        eprintln!("{}: {}", log_name, e);
        process::exit(1);
    }

    // 원본: result = "결과 메시지:\n" 로 시작해 분기에서 한 줄을 추가한다.
    let mut result = String::from("결과 메시지:\n");

    bar();
    println!("[SRV-090] 불필요한 원격 레지스트리 서비스 활성화");

    if check_remote_registry_service() {
        result.push_str("[취약]: 원격 레지스트리 서비스가 활성화되어 있는 경우\n");
        println!("원격 레지스트리 서비스가 활성화되어 있습니다.");
    } else {
        result.push_str("[양호]: 원격 레지스트리 서비스가 비활성화되어 있는 경우\n");
        println!("원격 레지스트리 서비스가 비활성화되어 있습니다.");
    }

    bar();

    // 원본: print(result) 후 print() — result 끝의 \n에 print의 \n이 더해지고,
    // 마지막 print()가 빈 줄을 하나 더 출력한다.
    print!("{}", result);
    println!();
    println!();
}
