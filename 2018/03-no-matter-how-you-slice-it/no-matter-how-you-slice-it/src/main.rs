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

type Fabric = HashMap<(i32,i32), Vec<i32>>;

fn populate_fabric(claims : &[Claim]) -> Fabric {
    let mut fabric = Fabric::new();
    for claim in claims.iter() {
        for x in 0..claim.width {
            for y in 0..claim.height {
                fabric.entry((x + claim.x, y + claim.y)).or_insert(Vec::new()).push(claim.id);
            }
        }
    }
    return fabric;
}

fn calculate_overlap(fabric: &Fabric) -> usize {
    fabric.values().filter(|v| (**v).len() > 1).count()
}

fn claim_has_overlaps(claim: &Claim, fabric: &Fabric) -> bool {
    for x in 0..claim.width {
        for y in 0..claim.height {
            match fabric.get(&(x+ claim.x, y + claim.y)) {
                Some(ids) => if ids.len() > 1 { return true },
                None => (),
            }
        }
    }
    return false;
}

fn find_non_overlapping(claims: &[Claim], fabric: &Fabric) -> Option<i32> {
    let mut singletons : Vec<i32> = fabric.values()
        .filter(|v| (**v).len() == 1)
        .flatten()
        .cloned() // needed to convert from pointers to values
        .collect();
    singletons.sort();
    singletons.dedup();

    for id in singletons {
        if !claim_has_overlaps(&claims[id as usize - 1], fabric) {
            return Some(id);
        }
    }
    None
}

fn main() -> io::Result<()> {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer)?;
    let claims : Vec<Claim> = buffer.lines().map(Claim::new).collect();

    let fabric = populate_fabric(&claims);
    println!("Overlap: {}", calculate_overlap(&fabric));
    println!("Non-overlapping id: {}", find_non_overlapping(&claims, &fabric).expect("No non-overlapping found!"));

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_overlap() {
        let input = vec!["#1 @ 1,3: 4x4", "#2 @ 3,1: 4x4", "#3 @ 5,5: 2x2"];
        let claims : Vec<Claim> = input.into_iter().map(Claim::new).collect();
        let fabric = populate_fabric(&claims);
        assert_eq!(calculate_overlap(&fabric), 4);
    }

    #[test]
    fn test_find_non_overlapping() {
        let input = vec!["#1 @ 1,3: 4x4", "#2 @ 3,1: 4x4", "#3 @ 5,5: 2x2"];
        let claims : Vec<Claim> = input.into_iter().map(Claim::new).collect();
        let fabric = populate_fabric(&claims);
        assert_eq!(find_non_overlapping(&claims, &fabric).unwrap(), 3);
    }

}
