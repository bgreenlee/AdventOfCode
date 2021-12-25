use std::io::{self, Read};

// cribbed from https://github.com/timvisee/advent-of-code-2021/blob/master/day18a/src/main.rs

// Snailfish sequence: `[(depth, n)]`
type Num = Vec<(u8, u8)>;

pub fn main() {
    let mut buffer = String::new();
    io::stdin()
        .read_to_string(&mut buffer)
        .expect("Error reading from stdin");

    let nums = parse(&buffer);
    println!("Part 1: {}", magnitude(&nums));
    println!("Part 2: {}", max_magnitude(&nums));
}

fn parse(buffer: &String) -> Vec<Num> {
    buffer.lines()
        .map(|line| {
            line.chars()
                .fold((0, Vec::new()), |(mut depth, mut num), c| {
                    match c {
                        '[' => depth += 1,
                        ']' => depth -= 1,
                        '0'..='9' => num.push((depth, c as u8 - '0' as u8)),
                        _ => {}
                    }
                    (depth, num)
                })
                .1 // return vector from tuple
        })
        .collect::<Vec<_>>()
}

// return final magnitude after adding and reducing
fn magnitude(nums: &Vec<Num>) -> u16 {
    let mut nums = nums.clone();
    while nums.len() > 1 {
        let mut other = nums.remove(1);
        let num = &mut nums[0];
        add(num, &mut other);
        reduce(num, 0);
    }

    mag(&mut 0, 1, &nums[0])
}

// return the max magnitude of adding any two numbers
fn max_magnitude(nums: &Vec<Num>) -> u16 {
    let mut max = 0;
    for i in 0..nums.len() - 1 {
        for j in i + 1..nums.len() {
            // we have to add each pair twice, since addition is non-commutative
            let (mut a1, mut b1) = (nums[i].clone(), nums[j].clone());
            let (mut a2, mut b2) = (a1.clone(), b1.clone());

            add(&mut a2, &mut b1);
            reduce(&mut a2, 0);
            max = mag(&mut 0, 1, &a2).max(max);

            add(&mut b2, &mut a1);
            reduce(&mut b2, 0);
            max = mag(&mut 0, 1, &b2).max(max);
        }
    }
    max
}

// add two snailfish numbers
// we append their arrays and increase all the depths by one
fn add(nums: &mut Num, other: &mut Num) {
    nums.append(other);
    nums.iter_mut().for_each(|(d, _)| *d += 1);
}

// reduce a snailfish number
// we alternatively explode and split until we can't anymore
fn reduce(nums: &mut Num, i: usize) {
    // explode
    for i in i..nums.len() - 1 {
        // If any pair is nested inside four pairs, the leftmost such pair explodes.
        if nums[i].0 == 5 {
            let (left, right) = (nums[i].1, nums[i + 1].1);
            nums[i] = (4, 0);
            nums.remove(i + 1);
            if i > 0 {
                nums.get_mut(i - 1).map(|n| n.1 += left);
            }
            nums.get_mut(i + 1).map(|n| n.1 += right);
            return reduce(nums, i);
        }
    }
    // split
    for i in 0..nums.len() {
        let (depth, n) = nums[i];
        // If any regular number is 10 or greater, the leftmost such regular number splits.
        if n >= 10 {
            nums[i] = (depth + 1, n / 2);
            nums.insert(i + 1, (depth + 1, (n + 1) / 2));
            return reduce(nums, i);
        }
    }
}

// recursively calculate the magnitude of this number
fn mag(i: &mut usize, depth: u8, num: &Num) -> u16 {
    3 * if num[*i].0 == depth {
        *i += 1;
        num[*i - 1].1 as u16
    } else {
        mag(i, depth + 1, num)
    }
    + 2 * if num[*i].0 == depth {
        *i += 1;
        num[*i - 1].1 as u16
    } else {
        mag(i, depth + 1, num)
    }
}