use std::collections::HashMap;
use std::io::{self, Read};

fn main() {
    let mut buffer = String::new();
    io::stdin()
        .read_to_string(&mut buffer)
        .expect("Error reading from stdin");
    let lines: Vec<&str> = buffer.lines().collect();

    // map of consecutive pairs of letters to their count in the "string"
    let mut pair_counts: HashMap<(char, char), u64> = HashMap::new();
    // map of substitution rules
    let mut rules: HashMap<(char, char), char> = HashMap::new();

    // get the pairs from our initial template string
    let initial: Vec<char> = lines[0].chars().collect();
    for i in 0..initial.len() - 1 {
        *pair_counts.entry((initial[i], initial[i + 1])).or_default() += 1;
    }
    // parse the rules
    for i in 2..lines.len() {
        let parts: Vec<_> = lines[i].split(" -> ").collect();
        let pair_chars: Vec<_> = parts[0].chars().collect();
        let new_element = parts[1].chars().nth(0).unwrap();
        rules.insert((pair_chars[0], pair_chars[1]), new_element);
    }

    for _ in 1..=40 {
        // clone our pair counts so we can update it as we iterate
        let mut new_pair_counts: HashMap<(char, char), u64> = pair_counts.clone();
        // iterate over our existing pairs, removing old pairs and creating new ones
        for (pair, count) in pair_counts.into_iter().filter(|(_, count)| *count > 0) {
            match rules.get_key_value(&pair) {
                Some((rule_pair, new_element)) => {
                    // remove old element
                    *new_pair_counts.entry(pair).or_default() -= count;
                    // add new elements
                    *new_pair_counts.entry((rule_pair.0, *new_element)).or_default() += count;
                    *new_pair_counts.entry((*new_element, rule_pair.1)).or_default() += count;
                }
                _ => {}
            }
        }
        pair_counts = new_pair_counts;
    }

    // get counts of individual elements
    let mut element_count: HashMap<char, u64> = HashMap::new();
    // we only count the first in each pair because of overlaps
    for (pair, count) in pair_counts {
        *element_count.entry(pair.0).or_default() += count;
    }
    // but we have to add in the last element of the initial template, which never changes
    *element_count.entry(initial[initial.len() - 1]).or_default() += 1;

    // sort the character counts and calculate the score
    let mut counts: Vec<_> = element_count.drain().collect();
    counts.sort_by(|a, b| a.1.partial_cmp(&b.1).unwrap());
    let score = counts[counts.len() - 1].1 - counts[0].1;
    println!("score: {}", score);
}
