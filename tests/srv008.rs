#[path = "../src/main.rs"]
mod srv008;

use std::fs;
use std::path::PathBuf;

fn tmpdir(tag: &str) -> PathBuf {
    let dir = std::env::temp_dir().join(format!("srv008-{}-{tag}", std::process::id()));
    fs::create_dir_all(&dir).unwrap();
    dir
}

fn run_case(tag: &str, sm: Option<&str>, pf: Option<&str>) -> (String, String) {
    let dir = tmpdir(tag);
    let log_path = dir.join("SRV-008.py.log");
    let mut out = Vec::new();
    srv008::run(sm, pf, &log_path, &mut out).unwrap();
    (
        String::from_utf8(out).unwrap(),
        fs::read_to_string(&log_path).unwrap(),
    )
}

#[test]
fn both_missing() {
    let (out, log) = run_case("casea", None, None);
    assert!(log.contains("INFO: Sendmail 설정 파일이 존재하지 않습니다."));
    assert!(log.contains("INFO: Postfix 설정 파일이 존재하지 않습니다."));
    assert!(log.starts_with("================================\n[SRV-008]"));
    assert_eq!(out, format!("{log}\n"));
}

#[test]
fn both_fully_set() {
    let sm = "O MaxDaemonChildren=10\nO ConnectionRateThrottle=2\nO MinFreeBlocks=100\nO MaxHeadersLength=32768\nO MaxMessageSize=1048576\n";
    let pf = "message_size_limit = 102400\nheader_size_limit = 4096\ndefault_process_limit = 50\nlocal_destination_concurrency_limit = 2\nsmtpd_recipient_limit = 100\n";
    let (_, log) = run_case("caseb", Some(sm), Some(pf));
    assert_eq!(log.matches("OK:").count(), 10);
    assert!(!log.contains("WARN"));
}

#[test]
fn sendmail_space_before_equals_is_warn() {
    // ^O\s*MaxDaemonChildren= does not match "O MaxDaemonChildren = 10".
    let (_, log) = run_case("casec", Some("O MaxDaemonChildren = 10\n"), None);
    assert!(log.contains("WARN: MaxDaemonChildren 설정이 적용되지 않았습니다."));
}

#[test]
fn sendmail_no_space_after_o_is_ok_and_postfix_prefix_collision() {
    // \s* allows zero whitespace: "OConnectionRateThrottle=2" matches.
    assert!(srv008::sendmail_has("OConnectionRateThrottle=2\n", "ConnectionRateThrottle"));
    // "header_size_limit_extra = 5" must not count as header_size_limit.
    assert!(!srv008::postfix_has("header_size_limit_extra = 5\n", "header_size_limit"));
    assert!(srv008::postfix_has("header_size_limit=4096\n", "header_size_limit"));
}

#[test]
fn both_empty_all_warn() {
    let (_, log) = run_case("casee", Some(""), Some(""));
    assert_eq!(log.matches("WARN:").count(), 10);
    // Sendmail block comes before the Postfix block.
    let sm_pos = log.find("Sendmail DoS 방지 설정을 점검 중입니다...").unwrap();
    let pf_pos = log.find("Postfix DoS 방지 설정을 점검 중입니다...").unwrap();
    assert!(sm_pos < pf_pos);
}
