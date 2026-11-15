#[path = "../src/main.rs"]
mod srv006;

use std::fs;
use std::path::PathBuf;

fn tmpdir(tag: &str) -> PathBuf {
    let dir = std::env::temp_dir().join(format!("srv006-{}-{tag}", std::process::id()));
    fs::create_dir_all(&dir).unwrap();
    dir
}

/// Returns (completed, stdout, log).
fn run_case(tag: &str, config: Option<&str>) -> (bool, String, String) {
    let dir = tmpdir(tag);
    let log_path = dir.join("SRV-006.py.log");
    let mut out = Vec::new();
    let done = srv006::run(config, &log_path, &mut out).unwrap();
    (
        done,
        String::from_utf8(out).unwrap(),
        fs::read_to_string(&log_path).unwrap(),
    )
}

#[test]
fn missing_file() {
    let (done, out, log) = run_case("casea", None);
    assert!(done);
    assert!(log.contains("INFO: sendmail 구성 파일(/etc/mail/sendmail.cf)을 찾을 수 없습니다."));
    assert!(log.starts_with("========================================\nCODE [SRV-006]"));
    assert!(log.contains("\"[SRV-006] SMTP 서비스 로그 수준 설정 미흡\""));
    assert_eq!(out, format!("{log}\n"));
}

#[test]
fn level_ok() {
    let (_, _, log) = run_case("caseb", Some("O LogLevel 9\n"));
    assert!(log.contains("OK: SMTP 서비스의 로그 수준이 적절하게 설정됨 (현재 수준: 9)."));
}

#[test]
fn level_low() {
    let (_, _, log) = run_case("casec", Some("O LogLevel 3\n"));
    assert!(log.contains("WARN: SMTP 서비스의 로그 수준이 낮게 설정됨 (현재 수준: 3)."));
}

#[test]
fn level_unset() {
    let (_, _, log) = run_case("cased", Some("# sendmail.cf\nO SomeOther 1\n"));
    assert!(log.contains("WARN: SMTP 서비스의 로그 수준이 낮게 설정됨 (현재 수준: 미설정)."));
}

#[test]
fn malformed_token_crashes_like_python() {
    // Python: int("abc") ValueError -> traceback, exit 1, stdout empty,
    // log keeps the five entries written before the check.
    let (done, out, log) = run_case("casee", Some("O LogLevel abc\n"));
    assert!(!done);
    assert!(out.is_empty());
    assert_eq!(log.lines().count(), 6); // 5 entries, one holding an embedded \n
    assert!(log.contains("\"[SRV-006] SMTP 서비스 로그 수준 설정 미흡\""));
    assert!(!log.contains("WARN") && !log.contains("OK: SMTP"));
}
