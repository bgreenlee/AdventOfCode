use std::io::{self, Read};
use std::collections::HashSet;

/// Finds the first duplicate frequency.
///
/// Starting with the initial frequency and applying the changes from
/// the given array of frequency changes repeatedly, return the first
/// frequency value that repeats.
///
/// There's no guarantee that this will ever finish. There should
/// probably be some sort of timeout, but this is only day 1.
///
/// # Example
///
/// ```
/// let result = doccomments::find_first_duplicate(0, [+3, +3, +4, -2, -4]);
/// assert_eq(result, 10);
/// ```
fn find_first_duplicate(mut frequency: i32, freq_changes: &[i32]) -> i32 {
    let mut seen_frequencies = HashSet::new();
    loop {
        for freq_change in freq_changes.iter() {
            frequency += freq_change;
            if seen_frequencies.contains(&frequency) {
                return frequency;
            }
            seen_frequencies.insert(frequency);
        }
    }
}

/// Read a list of frequency changes from stdin and print the first
/// duplicate frequency.
fn main() -> io::Result<()>  {
    // read input frequency changes into a vector
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer)?;
    let freq_changes: Vec<i32> = buffer.lines().map(|l|
        l.parse::<i32>().unwrap_or(0)
    ).collect();

    let duplicate = find_first_duplicate(0, &freq_changes);
    println!("First duplicate: {}", duplicate);
    Ok(())
}
