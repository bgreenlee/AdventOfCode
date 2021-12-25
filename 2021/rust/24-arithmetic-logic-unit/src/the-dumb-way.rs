use std::io::{self, Read};
use rand::prelude::*;

fn main() {
    let mut buffer = String::new();
    io::stdin()
        .read_to_string(&mut buffer)
        .expect("Error reading from stdin");
    let lines: Vec<&str> = buffer.lines().collect();
    let program = compile(&lines);

    let mut digits = Vec::with_capacity(14);
    let mut low = i64::MAX;
    for num in (44444444444444..=55555555555552).step_by(1000) {
        if num % 32 == 0 {
            continue;
        }
        digits.clear();
        let mut n = num;
        while n > 9 {
            digits.push(n % 10);
            n = n / 10;
        }
        digits.push(n);

        if digits.contains(&0) {
            continue;
        }

        if random::<u16>() == 0 {
            println!("{:?}", digits);
        }

        let input = digits.clone();
        let vars = execute(&program, &input);
        if vars[3] == 0 {
            println!("Bingo: {:?}", &input);
            break;
        }
        if vars[3] < low {
            low = vars[3];
            println!("{:?} => {}", &input, low);
        }
    }

    // let input: Vec<i64> = vec![6, 5, 4, 9, 1, 9, 5, 9, 7, 9, 9, 9, 9, 9];
    // let vars = execute(&program, &input);
    // println!("{}", vars[3]);
}

#[derive(PartialEq,Debug)]
enum Cmd { Inp, Add, Mul, Div, Mod, Eql }

type Instruction = (Cmd, char, Option<String>);

fn compile(lines: &Vec<&str>) -> Vec<Instruction> {
    let mut program: Vec<Instruction> = Vec::new();
    for line in lines {
        let parts: Vec<&str> = line.split_whitespace().collect();
        let cmd = match parts[0] {
            "inp" => Cmd::Inp,
            "add" => Cmd::Add,
            "mul" => Cmd::Mul,
            "div" => Cmd::Div,
            "mod" => Cmd::Mod,
            "eql" => Cmd::Eql,
            _ => panic!("Illegal instruction: {}", parts[0]),
        };
        let var = parts[1].chars().nth(0).unwrap();
        let arg = if parts.len() > 2 { Some(String::from(parts[2])) } else { None };
        program.push((cmd, var, arg));
    }
    program
}

fn execute(program: &Vec<Instruction>, input: &Vec<i64>) -> [i64; 4] {
    let mut input = input.clone();
    // encode our variables in an array, w = 0, x = 1, y = 2, z = 3
    let mut vars: [i64; 4] = [0; 4];
    for (cmd, var, arg) in program {
        // match arg {
        //     Some(a) => print!("{:?} {} {:3}", cmd, var, a),
        //     _ => print!("{:?} {}    ", cmd, var)
        // };
        // treat inp separately since it is the only one without a second argument
        let vi = (*var as u32 - 'w' as u32) as usize;
        // treat inp separately since it is the only one without a second argument
        if *cmd == Cmd::Inp {
            vars[vi] = input.pop().unwrap();
            // println!("{:6} {:6} {:6} {:6}", vars[0], vars[1], vars[2], vars[3]);
            continue;
        }
        let arg = match arg.as_ref().unwrap().parse::<i64>() {
            Ok(n) => n,
            _ => {
                let val = arg.as_ref().unwrap().chars().nth(0).unwrap();
                vars[(val as u32 - 'w' as u32) as usize]
            }
        };
        match cmd {
            Cmd::Add => vars[vi] += arg,
            Cmd::Mul => vars[vi] *= arg,            
            Cmd::Div => vars[vi] /= arg,            
            Cmd::Mod => vars[vi] %= arg,
            Cmd::Eql => vars[vi] = if vars[vi] == arg { 1 } else { 0 },
            _ => {},
        };
        // println!("{:6} {:6} {:6} {:6}", vars[0], vars[1], vars[2], vars[3]);
    }
    vars
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test1() {
        let input = vec![42];
        let program = compile(&vec![
            "inp x",
            "mul x -1"
        ]);
        let vars = execute(&program, &input);
        assert_eq!(vars[1], -42);
    }

    #[test]
    fn test2() {
        let input = vec![9, 3];
        let program = compile(&vec![
            "inp z",
            "inp x",
            "mul z 3",
            "eql z x",
        ]);
        let vars = execute(&program, &input);
        assert_eq!(vars[3], 1);
    }

    #[test]
    fn test3() {
        let input = vec![15];
        let program = compile(&vec![
            "inp w",
            "add z w",
            "mod z 2",
            "div w 2",
            "add y w",
            "mod y 2",
            "div w 2",
            "add x w",
            "mod x 2",
            "div w 2",
            "mod w 2",
        ]);
        let vars = execute(&program, &input);
        assert_eq!(vars[0], 1);
        assert_eq!(vars[1], 1);
        assert_eq!(vars[2], 1);
        assert_eq!(vars[3], 1);
    }
}

#[allow(unused_macros)]
macro_rules! dbg {
    ($x:expr) => {
        println!("{} = {:?}", stringify!($x), $x);
    };
}