use std::io::{self, BufRead};

fn main() {
    let mut frequency = 0;
    let stdin = io::stdin();
    for line in stdin.lock().lines() {
        match line {
            Ok(line) => match line.parse::<i32>() {
                Ok(n) => frequency += n,
                Err(_) => (), // ignore values that can't be parsed to ints
            }
            Err(err) => eprintln!("IO error: {}", err),
        }
    }
    println!("Frequency: {}", frequency);
}
