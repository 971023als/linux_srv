//! Test-branch-only harness: same logic as main.rs with injectable inputs.
//! Usage: harness <active:0|1> <ss_fixture_file> <log_path>
#[path = "../main.rs"]
mod srv;

use std::path::Path;

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let service_active = args[1] == "1";
    let ss_output = std::fs::read_to_string(&args[2]).unwrap_or_default();
    let stdout = std::io::stdout();
    if let Err(error) = srv::run(
        service_active,
        &ss_output,
        Path::new(&args[3]),
        &mut stdout.lock(),
    ) {
        eprintln!("{error}");
        std::process::exit(1);
    }
}
