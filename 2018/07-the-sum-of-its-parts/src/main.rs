use std::io::{self, Read};
use std::collections::HashSet;

fn main() {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer).expect("Error reading from stdin");
    let input : Vec<(char,char)> = buffer.lines()
        .map(|l| {
            let mut words = l.split_whitespace();
            let first = words.nth(1).unwrap_or("-");
            let second = words.nth(5).unwrap_or("-");
            (first.chars().nth(0).unwrap_or('-'),
             second.chars().nth(0).unwrap_or('-'))
        }).collect();

    let mut instructions : Vec<char> = Vec::new();
    for (a, b) in input {
        print!("{:?} => ", (a,b));
        let instr_clone = instructions.clone();
        let mut instructions_iter = instr_clone.iter();
        match instructions_iter.position(|c| *c == a) {
            Some(a_idx) => // found a, so look for a place to insert b
                match instructions_iter.position(|c| *c > b) {
                    Some(insert_offset_idx) => instructions.insert(a_idx + insert_offset_idx + 1, b),
                    None => instructions.push(b),
                },
            None => {
                // not found, add them both to the end
                instructions.push(a);
                instructions.push(b);
            }
        }
        let state : String = instructions.iter().by_ref().collect();
        println!("{}", state);
    }

    // we now need to iterate through the instructions from the end, removing any duplicates
    let mut seen = HashSet::new();
    let filtered_instructions : Vec<&char> = instructions.iter().rev()
        .filter(|&c| if seen.contains(c) {
            false
        } else {
            seen.insert(*c);
            true
        }).collect();
//    println!("{:#?}", input);
    let answer : String = filtered_instructions.iter().cloned().rev().collect();
    println!("{}", answer)
}
