//! SRV-094 (로그 기록 정책 점검) Rust 시범 포팅.
//!
//! 원본: linux_srv/python/SRV-094.py (유지됨, 이 포팅이 대체하지 않음)
//!
//! 목표: 원본과 동일한 stdout 문구/순서와 SRV-094.log 생성 동작.
//! 표준 라이브러리만 사용하며 외부 크레이트는 없다.
//!
//! 원본 불일치 보존: 원본의 출력 제목은 "[SRV-094] crontab 참조파일 권한 설정
//! 미흡"이지만 실제 점검 대상은 /etc/rsyslog.conf이다. 이 불일치는 원본 동작
//! 그대로 보존하며, 이 포팅에서 수정하지 않는다.
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
//! - Python의 `line in content`(str 부분열 검사)와 Rust의 str::contains는
//!   기대 라인이 모두 ASCII라 이 경우 동일 의미로 예상되나, 실행 비교는
//!   수행하지 않았다.
//! - Path::exists는 os.path.exists와 같은 의도(심볼릭 링크 추적, 오류 시
//!   false)로 사용했으나, 모든 파일시스템 오류 경로에서의 동일성은 검증되지
//!   않았다.

use std::fs::{self, File};
use std::path::Path;
use std::process;

const SCRIPT_NAME: &str = "SRV-094";
const RSYSLOG_CONF: &str = "/etc/rsyslog.conf";

// 원본 result_msg와 동일한 문자열 (끝의 \n 포함).
// Python의 print(result_msg)는 여기에 \n을 하나 더 붙여 출력한다.
const RESULT_MSG: &str = "[양호]: 로그 기록 정책이 정책에 따라 설정되어 수립되어 있는 경우\n[취약]: 로그 기록 정책이 정책에 따라 설정되어 수립되어 있지 않은 경우\n";

// 원본 expected_content 리스트와 동일한 6개 기대 라인.
const EXPECTED_CONTENT: [&str; 6] = [
    "*.info;mail.none;authpriv.none;cron.none /var/log/messages",
    "authpriv.* /var/log/secure",
    "mail.* /var/log/maillog",
    "cron.* /var/log/cron",
    "*.alert /dev/console",
    "*.emerg *",
];

fn bar() {
    // 원본: print("-" * 40)
    println!("----------------------------------------");
}

fn check_rsyslog_config() {
    // 원본: /etc/rsyslog.conf 부재 시 WARN 출력 후 반환
    if !Path::new(RSYSLOG_CONF).exists() {
        println!("WARN: {} 가 존재하지 않습니다", RSYSLOG_CONF);
        return;
    }

    // 원본은 파일 전체를 한 번에 읽어 부분열 포함 여부를 확인한다.
    // 읽기 실패 시 Python은 traceback으로 종료하므로, 여기서도 오류 후 종료한다.
    let content = match fs::read_to_string(RSYSLOG_CONF) {
        Ok(c) => c,
        Err(e) => {
            eprintln!("{}: {}", RSYSLOG_CONF, e);
            process::exit(1);
        }
    };

    let mut matched = 0;
    for line in EXPECTED_CONTENT {
        if content.contains(line) {
            matched += 1;
        }
    }

    if matched == EXPECTED_CONTENT.len() {
        println!("OK: {}의 내용이 정확합니다.", RSYSLOG_CONF);
    } else {
        println!("WARN: {}의 내용에 일부 설정이 누락되었습니다.", RSYSLOG_CONF);
    }
}

fn main() {
    // 원본 모듈 최상단과 같은 순서로, 먼저 CWD에 SRV-094.log를 생성/초기화한다.
    // (원본도 내용을 기록하지 않고 빈 파일로 남긴다)
    let log_name = format!("{}.log", SCRIPT_NAME);
    if let Err(e) = File::create(&log_name) {
        // Python도 open() 실패 시 예외로 종료한다. 출력 형태만 다르다.
        eprintln!("{}: {}", log_name, e);
        process::exit(1);
    }

    bar();
    // 원본 제목 그대로 (실제 점검은 rsyslog이지만 수정하지 않음)
    println!("[SRV-094] crontab 참조파일 권한 설정 미흡");
    bar();

    check_rsyslog_config();

    // 원본: print(result_msg) — result_msg 끝의 \n에 print의 \n이 더해진다.
    println!("{}", RESULT_MSG);
}
