use std::io::{self, Read};

fn main() {
    let mut buffer = String::new();
    io::stdin()
        .read_to_string(&mut buffer)
        .expect("Error reading from stdin");
    let lines: Vec<&str> = buffer.lines().collect();

    let mut part1_score = 0;
    let mut part2_scores: Vec<u64> = Vec::new();
    for line in lines {
        let mut stack: Vec<char> = Vec::new();
        let score = corruption_score(&mut stack, line);
        if score > 0 {
            part1_score += score
        } else {
            part2_scores.push(complete(&mut stack));
        }
    }
    // get median score
    part2_scores.sort();
    let part2_score = part2_scores[part2_scores.len() / 2];

    println!("Part 1: {}", part1_score);
    println!("Part 2: {}", part2_score);
}

fn corruption_score(stack: &mut Vec<char>, line: &str) -> i32 {
    for c in line.chars() {
        match c {
            // open character, put it on the stack
            '(' | '[' | '{' | '<' => stack.push(c),
            // close character, check that we have a matching open on the stack
            ')' | ']' | '}' | '>' => {
                match stack.pop() {
                    // if we have a matching open, move on
                    Some('(') if c == ')' => {},
                    Some('[') if c == ']' => {},
                    Some('{') if c == '}' => {},
                    Some('<') if c == '>' => {},
                    // non-matching character, so we have corruption; return the score
                    _ => return match c {
                        ')' => 3,
                        ']' => 57,
                        '}' => 1197,
                        '>' => 25137,
                        _ => panic!(), // bad input
                    }
                };
            },
            _ => panic!(), // bad input
        }
    }
    return 0; // all good
}

fn complete(stack: &mut Vec<char>) -> u64 {
    let mut score = 0;
    loop {
        let next = stack.pop();
        score = score * 5 + match next {
            Some('(') => 1,
            Some('[') => 2,
            Some('{') => 3,
            Some('<') => 4,
            _ => break,
        }
    }
    return score;
}