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
        let (corrupted, s) = is_corrupted(&mut stack, line);
        if corrupted {
            part1_score += s
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

fn is_corrupted(stack: &mut Vec<char>, line: &str) -> (bool, i32) {
    let mut valid = false;
    let mut score = 0;
    for c in line.chars() {
        match c {
            '(' | '[' | '{' | '<' => stack.push(c),
            ')' | ']' | '}' | '>' => {
                let x = stack.pop();
                valid = match x {
                    Some('(') if c == ')' => true,
                    Some('[') if c == ']' => true,
                    Some('{') if c == '}' => true,
                    Some('<') if c == '>' => true,
                    _ => false,
                };
                if !valid {
                    score += match c {
                        ')' => 3,
                        ']' => 57,
                        '}' => 1197,
                        '>' => 25137,
                        _ => 0,
                    };
                    break;
                }
            },
            _ => panic!()
        }
    }
    return (!valid, score)
}

fn complete(stack: &mut Vec<char>) -> u64 {
    let mut score = 0;
    loop {
        let next = stack.pop();
        match next {
            Some('(') => score = score * 5 + 1,
            Some('[') => score = score * 5 + 2,
            Some('{') => score = score * 5 + 3,
            Some('<') => score = score * 5 + 4,
            _ => break,
        }
    }
    return score;
}