use std::io::{self, Read};
use std::collections::{HashMap, HashSet};
use std::ops::Deref;
use std::hash::{Hash, Hasher};
use std::cmp::{Eq, PartialEq};

// create a type for segments, which is just a set of chars
struct Segments(HashSet<char>);

// this gives us HashSet's methods
impl Deref for Segments {
    type Target = HashSet<char>;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

// implement our own hash since rust doesn't provide one for HashSet
impl Hash for Segments {
    fn hash<H: Hasher>(&self, state: &mut H) {
        let mut chars: Vec<&char> = self.iter().collect();
        chars.sort();
        chars.hash(state);
    }
}
impl PartialEq for Segments {
    fn eq(&self, other: &Segments) -> bool {
        self.0 == other.0
    }
}
impl Eq for Segments {}


fn main() {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer)
        .expect("Error reading from stdin");
    let lines: Vec<&str> = buffer.lines().collect();

    let mut part1_total: u32 = 0;
    let mut part2_total: u32 = 0;
    for line in lines {
        let parts: Vec<&str> = line.split(" | ").collect();

        let input_segments: Vec<Segments> = parts[0].split(" ")
            .map(|s| Segments(HashSet::from_iter(s.chars())))
            .collect();

        let output_segments: Vec<Segments> = parts[1].split(" ")
            .map(|s| Segments(HashSet::from_iter(s.chars())))
            .collect();

        part1_total += output_segments.iter()
            .filter(|s| s.len() < 5 || s.len() > 6)
            .count() as u32;

        let mapping = generate_mapping(&input_segments);
        part2_total += segments_to_number(&output_segments, &mapping);
    }

    println!("Part 1: {}", part1_total);
    println!("Part 2: {}", part2_total);
}

// given a vector of input segments, produce a mapping of segment -> number
fn generate_mapping(segments: &Vec<Segments>) -> HashMap<&Segments, u8> {
    // find our base set of {1,4,7,8}
    let one = segments.iter().find(|s| s.len() == 2).unwrap();
    let four = segments.iter().find(|s| s.len() == 4).unwrap();
    let seven = segments.iter().find(|s| s.len() == 3).unwrap();
    let eight = segments.iter().find(|s| s.len() == 7).unwrap();

    // find the rest
    let zero = segments.iter().find(|s|
        s.len() == 6 && 
        !s.is_superset(four) && s.is_superset(seven))
        .unwrap();
    let three = segments.iter().find(|s|
        s.len() == 5 && 
        s.is_superset(seven))
        .unwrap();
    let six = segments.iter().find(|s|
        s.len() == 6 && 
        !s.is_superset(one))
        .unwrap();
    let nine = segments.iter().find(|s|
        s.len() == 6 && 
        s.is_superset(one) && s.is_superset(four))
        .unwrap();
    let two = segments.iter().find(|s|
        s.len() == 5 && 
        !s.is_superset(one) && !s.is_subset(six))
        .unwrap();
    let five = segments.iter().find(|s|
        s.len() == 5 && 
        s.is_subset(six))
        .unwrap();
        
    let mut mapping: HashMap<&Segments, u8> = HashMap::new();
    mapping.insert(zero, 0);
    mapping.insert(one, 1);
    mapping.insert(two, 2);
    mapping.insert(three, 3);
    mapping.insert(four, 4);
    mapping.insert(five, 5);
    mapping.insert(six, 6);
    mapping.insert(seven, 7);
    mapping.insert(eight, 8);
    mapping.insert(nine, 9);

    return mapping;
}

// Convert a vector of segments to its number representation
fn segments_to_number(segments: &Vec<Segments>, mapping: &HashMap<&Segments, u8>) -> u32 {
    let digits: Vec<u8> = segments.iter()
        .map(|s| *mapping.get(&s).unwrap())
        .collect();
    let mut number: u32 = 0;
    for i in 0..digits.len() {
        number += 10u32.pow((digits.len() - i) as u32 - 1) * digits[i] as u32;
    }
    return number;
}