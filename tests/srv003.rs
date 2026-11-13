#[path = "../src/main.rs"]
mod srv003;

use std::fs;
use std::path::PathBuf;

fn tmpdir(tag: &str) -> PathBuf {
    let dir = std::env::temp_dir().join(format!("srv003-{}-{tag}", std::process::id()));
    fs::create_dir_all(&dir).unwrap();
    dir
}

fn run_case(tag: &str, ps: &str, conf: Option<&str>) -> (String, String) {
    let dir = tmpdir(tag);
    let conf_path = dir.join("snmpd.conf");
    if let Some(contents) = conf {
        fs::write(&conf_path, contents).unwrap();
    }
    let log_path = dir.join("SRV-003.py.log");
    let mut out = Vec::new();
    srv003::run(ps, &conf_path, &log_path, &mut out).unwrap();
    (
        String::from_utf8(out).unwrap(),
        fs::read_to_string(&log_path).unwrap(),
    )
}

#[test]
fn service_not_running() {
    // Only a grep line matches snmp: grep -v 'grep' parity excludes it.
    let (stdout, log) = run_case("notrun", "user 123 0.0 grep -i snmp\n", None);
    assert!(log.contains("OK: SNMP 서비스가 실행 중이지 않습니다."));
    assert!(stdout.starts_with(
        "--------------------------------------------------\n--------------------------------------------------\n--------------------------------------------------\nCODE [SRV-003]"
    ));
    assert!(stdout.ends_with("OK: SNMP 서비스가 실행 중이지 않습니다.\n\n"));
}

#[test]
fn weak_case_a() {
    let (_, log) = run_case("casea", "snmpd 1 0.0 /usr/sbin/snmpd\n", Some("rouser admin\n"));
    assert!(log.contains("WARN: SNMP 접근 제어 설정이 불충분함"));
}

#[test]
fn weak_case_b_uppercase() {
    let (_, log) = run_case("caseb", "SNMPD 1 0.0 /usr/sbin/snmpd\n", Some("RWUSER admin\n"));
    assert!(log.contains("WARN: SNMP 접근 제어 설정이 불충분함"));
}

#[test]
fn clean_configuration() {
    let (_, log) = run_case("clean", "snmpd 1 0.0 /usr/sbin/snmpd\n", Some("rocommunity S3cure-String!\n"));
    assert!(log.contains("OK: SNMP 접근 제어 설정이 적절함"));
}

#[test]
fn missing_configuration_file() {
    let (_, log) = run_case("missing", "snmpd 1 0.0 /usr/sbin/snmpd\n", None);
    assert!(log.contains("WARN: SNMP 구성 파일("));
    assert!(log.contains("을 찾을 수 없음"));
}
