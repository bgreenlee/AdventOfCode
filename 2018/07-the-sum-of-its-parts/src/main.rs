use std::io::{self, Read};
use std::collections::{BTreeMap, HashSet};

fn main() {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer).expect("Error reading from stdin");
    // parse the input lines into tuples
    let input : Vec<(char,char)> = buffer.lines()
        .map(|l| {
            let mut words = l.split_whitespace();
            let first = words.nth(1).unwrap_or("-");
            let second = words.nth(5).unwrap_or("-");
            (first.chars().nth(0).unwrap_or('-'),
             second.chars().nth(0).unwrap_or('-'))
        }).collect();

    let mut completed : Vec<char> = Vec::new();
    let mut dependencies : BTreeMap<char, HashSet<char>> = BTreeMap::new();
    for (a, b) in input {
        dependencies.entry(a).or_insert(HashSet::new());
        let mut deps = dependencies.entry(b).or_insert(HashSet::new());
        deps.insert(a);
    }

    let total_steps = dependencies.keys().len();
    while completed.len() < total_steps {
        // anything without dependencies we can move to completed
        for (step, deps) in dependencies.iter().by_ref() {
            if deps.is_empty() && !completed.contains(step) {
                completed.push(*step);
                break;
            }
        }

        // now remove all completed from the dependencies
        for (_, mut deps) in dependencies.iter_mut() {
            if !deps.is_empty() {
                for c in completed.iter().by_ref() {
                    deps.remove(&c);
                }
            }
        }
    }

    let answer : String = completed.iter().collect();
    println!("{:#?}", answer);
}
