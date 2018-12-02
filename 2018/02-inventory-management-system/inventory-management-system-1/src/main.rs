use std::io::{self, Read};
use std::collections::HashMap;

/// Return the score for an id.
///
/// The score is a tuple (a,b), where a is true if the id contains exactly
/// two of any letter, and b is true if the id contains exactly three of any
/// letter.
///
/// # Examples
///
/// ```
/// assert_eq(doccomments::score("abcdef"), (false, false));
/// assert_eq(doccomments::score("bababc"), (true,  true));
/// assert_eq(doccomments::score("abbcde"), (true,  false));
/// assert_eq(doccomments::score("abcccd"), (false, true));
/// ```
///
fn score(id: &str) -> (bool, bool) {
    let mut char_counts = HashMap::new();
    for c in id.chars() {
        *char_counts.entry(c).or_insert(0) += 1;
    }

    let mut has_two = false;
    let mut has_three = false;

    for count in char_counts.values() {
        if *count == 2 {
            has_two = true;
        }
        if *count == 3 {
            has_three = true;
        }
        if has_two && has_three {
            break; // can stop early
        }
    }
    return (has_two, has_three);
}

/// Calculate the checksum of an array of ids
///
/// # Example
///
/// ```
/// let result = doccomments::checksum(["abcdef", "bababc", "abbcde", "abcccd", "aabcdd", "abcdee", "ababab"]);
/// assert_eq(result, 12);
/// ```
fn checksum(ids: &[&str]) -> i32 {
    let mut two_count = 0;
    let mut three_count = 0;
    for id in ids.iter() {
        let (has_two, has_three) = score(*id);
        if has_two {
            two_count += 1;
        }
        if has_three {
            three_count += 1;
        }
    }

    return two_count * three_count;
}

fn main() -> io::Result<()>  {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer)?;
    let ids :Vec<&str> = buffer.lines().collect();
    let checksum = checksum(&ids);
    println!("Checksum: {}", checksum);
    Ok(())
}
