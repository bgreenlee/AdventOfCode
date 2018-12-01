use std::io::{self, Read};
use std::collections::HashSet;

fn main() -> io::Result<()>  {
    // read input frequency changes into a vector
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer)?;
    let freq_changes: Vec<i32> = buffer.lines().map(|l|
        l.parse::<i32>().unwrap_or(0)
    ).collect();

    let mut frequency = 0;
    let mut seen_frequencies = HashSet::new();
    let mut found_duplicate = false;

    while !found_duplicate {
        for freq_change in freq_changes.iter() {
            frequency += freq_change;
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
