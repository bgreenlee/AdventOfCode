use std::io::{self, Read};
use std::collections::HashMap;

#[derive(Debug)]
struct Claim {
    id: i32,
    x: i32,
    y: i32,
    width: i32,
    height: i32,
}

impl Claim {
    fn new(claim_str: &str) -> Claim {
        let parts : Vec<i32> = claim_str
            .split(|c:char| !c.is_numeric())
            .filter(|c| !c.is_empty())
            .map(|c| (*c).parse::<i32>().unwrap_or(0))
            .collect();

        Claim {
            id: parts[0],
            x: parts[1],
            y: parts[2],
            width: parts[3],
            height: parts[4],
        }
    }
}

fn calculate_overlap(claims : &[&str]) -> usize {
    let mut fabric = HashMap::new();
    for claim_str in claims.iter() {
        let claim = Claim::new(claim_str);
        for x in 0..claim.width {
            for y in 0..claim.height {
                *fabric.entry((x + claim.x, y + claim.y)).or_insert(0) += 1;
            }
        }
    }

    return fabric.values().filter(|v| **v > 1).count();
}

fn main() -> io::Result<()> {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer)?;
    let claims : Vec<&str> = buffer.lines().collect();

    println!("{}", calculate_overlap(&claims));

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_overlap() {
        let claims = ["#1 @ 1,3: 4x4", "#2 @ 3,1: 4x4", "#3 @ 5,5: 2x2"];
        assert_eq!(calculate_overlap(&claims), 4);
    }
}
