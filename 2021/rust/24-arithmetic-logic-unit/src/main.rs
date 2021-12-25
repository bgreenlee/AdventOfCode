use std::io::{self, Read};

fn main() {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer)
        .expect("Error reading from stdin");
    let lines: Vec<&str> = buffer.lines().collect();
    
    println!("Part 1: {}", solve(&lines, true));
    println!("Part 2: {}", solve(&lines, false));
}

// cribbed from https://www.reddit.com/r/adventofcode/comments/rnejv5/comment/hpuo5c6/?utm_source=share&utm_medium=web2x&context=3
fn solve(lines: &Vec<&str>, find_largest: bool) -> u64 {
    let mut stack = Vec::new();
    let mut digits = [0u8; 14];
    for i in 0..14 {
        let x_add = lines[18 * i + 5].split_whitespace().last().unwrap().parse::<i32>().unwrap();
        let y_add = lines[18 * i + 15].split_whitespace().last().unwrap().parse::<i32>().unwrap();
        if x_add > 0 {
            stack.push((y_add, i));
        } else {
            let (y_add, y_idx) = stack.pop().unwrap();
            let mut to_add;
            if find_largest {
                to_add = 9;
                while to_add + y_add + x_add > 9 {
                    to_add -= 1;
                }
            } else {
                to_add = 1;
                while to_add + y_add + x_add < 1 {
                    to_add += 1;
                }
            }
            digits[y_idx as usize] = to_add as u8;
            digits[i] = (to_add + y_add + x_add) as u8;
        }
    }
    // convert our digits array to a number
    let mut answer = 0u64;
    for i in (0..digits.len()).rev() {
        answer += (digits[i] as u64) * 10u64.pow(i as u32);
    }
    answer
}