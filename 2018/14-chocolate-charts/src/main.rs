use std::env;
use std::process::exit;

fn main() {
    if env::args().len() < 2 {
        println!("Usage: chocolate-charts <iterations>");
        exit(1);
    }

    let iterations = env::args().nth(1).unwrap()
        .parse::<usize>().expect("Could not parse input.");
    let mut recipes = vec![3, 7];
    let mut elf_a = 0;
    let mut elf_b = 1;

    while recipes.len() < iterations + 10 {
        //println!("({},{}) => {:?}", elf_a, elf_b, recipes);
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
    println!("{}", answer);
}
