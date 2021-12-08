use std::io::{self, Read};
use std::collections::{HashMap, HashSet};
use std::ops::Deref;
use std::hash::{Hash, Hasher};
use std::cmp::{Eq, PartialEq};

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

    let mut total: u32 = 0;
    for line in lines {
        let parts: Vec<&str> = line.split(" | ").collect();

        let input_segments: Vec<Segments> = parts[0].split(" ")
            .map(|s| Segments(HashSet::from_iter(s.chars())))
            .collect();

        let output_segments: Vec<Segments> = parts[1].split(" ")
            .map(|s| Segments(HashSet::from_iter(s.chars())))
            .collect();

        let mapping = generate_mapping(&input_segments);
        total += segments_to_number(&output_segments, &mapping);
    }

    println!("{}", total);
}

fn generate_mapping(input_segments: &Vec<Segments>) -> HashMap<&Segments, u8> {
    // find our base set of {1,4,7,8}
    let one = input_segments.iter().find(|s| s.len() == 2).unwrap();
    let four = input_segments.iter().find(|s| s.len() == 4).unwrap();
    let seven = input_segments.iter().find(|s| s.len() == 3).unwrap();
    let eight = input_segments.iter().find(|s| s.len() == 7).unwrap();

    // find the rest
    let zero = input_segments.iter().find(|s|
        s.len() == 6 && 
        s.is_superset(one) && s.is_superset(seven) && !s.is_superset(four))
        .unwrap();
    let three = input_segments.iter().find(|s|
        s.len() == 5 && 
        s.is_superset(one) && s.is_superset(seven))
        .unwrap();
    let six = input_segments.iter().find(|s|
        s.len() == 6 && 
        !s.is_superset(one))
        .unwrap();
    let nine = input_segments.iter().find(|s|
        s.len() == 6 && 
        s.is_superset(one) && s.is_superset(four))
        .unwrap();
    let two = input_segments.iter().find(|s|
        s.len() == 5 && 
        !s.is_subset(six) &&
        !s.is_superset(one))
        .unwrap();
    let five = input_segments.iter().find(|s|
        s.len() == 5 && 
        s.is_subset(six) &&
        !s.is_superset(one))
        .unwrap();
        
    // we use a string as our key because HashSet isn't hashable
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