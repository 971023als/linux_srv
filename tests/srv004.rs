#[path = "../src/main.rs"]
mod srv004;

use std::fs;
use std::path::PathBuf;

const SS_CLOSED: &str =
    "Netid State Recv-Q Send-Q Local Address:Port Peer Address:Port\ntcp LISTEN 0 100 0.0.0.0:22 0.0.0.0:*\n";
const SS_OPEN: &str =
    "Netid State Recv-Q Send-Q Local Address:Port Peer Address:Port\ntcp LISTEN 0 100 0.0.0.0:25 0.0.0.0:*\n";

fn tmpdir(tag: &str) -> PathBuf {
    let dir = std::env::temp_dir().join(format!("srv004-{}-{tag}", std::process::id()));
    fs::create_dir_all(&dir).unwrap();
    dir
}

fn run_case(tag: &str, active: bool, ss: &str) -> (String, String) {
    let dir = tmpdir(tag);
    let log_path = dir.join("SRV-004.py.log");
    let mut out = Vec::new();
    srv004::run(active, ss, &log_path, &mut out).unwrap();
    (
        String::from_utf8(out).unwrap(),
        fs::read_to_string(&log_path).unwrap(),
    )
}

#[test]
fn inactive_closed() {
    let (out, log) = run_case("casea", false, SS_CLOSED);
    assert!(log.contains("OK: postfix 서비스가 비활성화되어 있거나 실행 중이지 않습니다."));
    assert!(log.contains("OK: SMTP 포트(25)는 닫혀 있습니다."));
    assert!(log.starts_with("--------------------------------------------------\nCODE [SRV-004]"));
    assert_eq!(out, format!("{log}\n"));
}

#[test]
fn active_closed() {
    let (_, log) = run_case("caseb", true, SS_CLOSED);
    assert!(log.contains("WARN: postfix 서비스가 실행 중입니다."));
    assert!(log.contains("OK: SMTP 포트(25)는 닫혀 있습니다."));
}

#[test]
fn inactive_open() {
    let (_, log) = run_case("casec", false, SS_OPEN);
    assert!(log.contains("OK: postfix 서비스가 비활성화되어 있거나 실행 중이지 않습니다."));
    assert!(log.contains("WARN: SMTP 포트(25)가 열려 있습니다. 불필요한 서비스가 실행 중일 수 있습니다."));
}

#[test]
fn active_open() {
    let (_, log) = run_case("cased", true, SS_OPEN);
    assert!(log.contains("WARN: postfix 서비스가 실행 중입니다."));
    assert!(log.contains("WARN: SMTP 포트(25)가 열려 있습니다. 불필요한 서비스가 실행 중일 수 있습니다."));
}

#[test]
fn port_match_needs_trailing_space() {
    // ":250 " and ":125 " must not count as port 25; ":25" at end of line
    // without a trailing space must not count either.
    let ss = "tcp LISTEN 0 100 0.0.0.0:250 0.0.0.0:*\ntcp LISTEN 0 100 0.0.0.0:125 0.0.0.0:*\n";
    assert!(!srv004::port_open(ss, 25));
    assert!(!srv004::port_open("tcp LISTEN 0 100 0.0.0.0:25\n", 25));
    assert!(srv004::port_open(SS_OPEN, 25));
}
