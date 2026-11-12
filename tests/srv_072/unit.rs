#[allow(dead_code)]
#[path = "pilot_source.rs"] mod pilot;
use std::{fs,path::PathBuf};
fn case(name:&str, input:Option<&str>, seed:&str, expected:&str) {
    let dir=std::env::temp_dir().join(format!("srv072-unit-{}-{name}",std::process::id()));
    fs::create_dir_all(&dir).unwrap();
    let passwd:PathBuf=dir.join("passwd"); let log=dir.join("log");
    if let Some(value)=input { fs::write(&passwd,value).unwrap(); }
    if !seed.is_empty() { fs::write(&log,seed).unwrap(); }
    let mut output=Vec::new();
    pilot::run(&passwd,&log,&mut output).unwrap();
    assert_eq!(String::from_utf8(output).unwrap(),format!("{seed}{expected}\n\n"));
    assert_eq!(fs::read_to_string(&log).unwrap(),format!("{seed}{expected}\n"));
    fs::remove_dir_all(dir).unwrap();
}
#[test] fn present(){case("present",Some("Administrator"),"","기본 'Administrator' 계정이 존재합니다.");}
#[test] fn absent(){case("absent",Some("root"),"","기본 'Administrator' 계정이 존재하지 않습니다.");}
#[test] fn case_sensitive(){case("lower",Some("administrator"),"","기본 'Administrator' 계정이 존재하지 않습니다.");}
#[test] fn missing(){case("missing",None,"","파일을 찾을 수 없습니다: /etc/passwd");}
#[test] fn append(){case("append",Some("root"),"old\n","기본 'Administrator' 계정이 존재하지 않습니다.");}
