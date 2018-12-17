use std::env;
use std::process::exit;

fn part1(input: &str) {
    let iterations = input.parse::<usize>().expect("Could not parse input.");
    let mut recipes = vec![3, 7];
    let mut elf_a = 0;
    let mut elf_b = 1;

    while recipes.len() < iterations + 10 {
        let sum = recipes[elf_a] + recipes[elf_b];
        if sum < 10 {
            recipes.push(sum);
        } else {
            recipes.push(1);
            recipes.push(sum - 10);
        }
        elf_a = (elf_a + recipes[elf_a] + 1) % recipes.len();
        elf_b = (elf_b + recipes[elf_b] + 1) % recipes.len();
    }

    let digits = &recipes[recipes.len()-10..];
    let answer = digits.iter().map(|d| d.to_string()).collect::<String>();
    println!("part1: {}", answer);
}

fn is_match(recipes: &Vec<usize>, input_digits: &Vec<usize>) -> bool {
    if recipes.len() < input_digits.len() {
        return false;
    }
    for (i, d) in input_digits.iter().enumerate() {
        if &recipes[recipes.len()-input_digits.len()+i] != d {
            return false;
        }
    }
    true
}

fn part2(input: &str) {
    let mut recipes = vec![3, 7];
    let mut elf_a = 0;
    let mut elf_b = 1;
    let input_digits: Vec<_> = input.chars().map(|d| d.to_digit(10).unwrap() as usize).collect();
    let input_digits_len = input_digits.len();

    loop {
        let sum = recipes[elf_a] + recipes[elf_b];
        if sum < 10 {
            recipes.push(sum);
            if is_match(&recipes, &input_digits) { break }
        } else {
            recipes.push(1);
            if is_match(&recipes, &input_digits) { break }
            recipes.push(sum - 10);
            if is_match(&recipes, &input_digits) { break }
        }
        elf_a = (elf_a + recipes[elf_a] + 1) % recipes.len();
        elf_b = (elf_b + recipes[elf_b] + 1) % recipes.len();
    }

    let answer = recipes.len() - input_digits_len;
    println!("part2: {}", answer);
}

fn main() {
    if env::args().len() < 2 {
        println!("Usage: chocolate-charts <iterations>");
        exit(1);
    }

    let input = env::args().nth(1).unwrap();

    part1(&input);
    part2(&input);
}