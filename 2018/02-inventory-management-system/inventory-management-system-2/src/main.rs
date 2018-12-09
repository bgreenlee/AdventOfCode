use std::io::{self, Read};

/// Return the overlap between two strings.
///
/// Given two strings, return a string representing the overlap between the
/// strings, where overlap is defined as characters from both strings that
/// are in the same position in each string.
fn overlap(a: &str, b: &str) -> String {
    let mut result = String::new();
    for (i, c) in a.char_indices() {
        if b.chars().nth(i) == Some(c) { // this is probably super inefficient
            result.push(c);
        }
    }
    return result;
}

fn main() -> io::Result<()>  {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer)?;
    let ids : Vec<&str> = buffer.lines().collect();

    // This is the dumbest way to do this, but until I figure out something more efficient....
    let num_ids = ids.iter().count();
    'outer: for i in 0..(num_ids - 1) {
        for j in (i+1)..num_ids {
            let overlap = overlap(ids[i], ids[j]);
            if overlap.len() == ids[i].len() - 1 {
                println!("{}", overlap);
                break 'outer;
            }
        }
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn test_overlap() {
        assert_eq!(overlap("abc", "abc"), "abc");
        assert_eq!(overlap("abc", "axc"), "ac");
        assert_eq!(overlap("abc", "def"), "");
    }
}