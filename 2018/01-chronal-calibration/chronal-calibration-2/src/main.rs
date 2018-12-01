use std::io::{self, Read};
use std::collections::HashSet;

fn main() -> io::Result<()>  {
    // read input frequencies into a string
    let mut frequencies = String::new();
    io::stdin().read_to_string(&mut frequencies)?;

    let mut frequency = 0;
    let mut seen_frequencies = HashSet::new();
    let mut found_duplicate = false;

    while !found_duplicate {
        for line in frequencies.lines() {
            match line.parse::<i32>() {
                Ok(n) => frequency += n,
                Err(_) => (), // ignore values that can't be parsed to ints
            }
            if seen_frequencies.contains(&frequency) {
                println!("First duplicate: {}", frequency);
                found_duplicate = true;
                break;
            }
            seen_frequencies.insert(frequency);
        }
    }
    Ok(())
}
