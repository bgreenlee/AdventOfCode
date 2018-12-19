use std::io::{self, Read};
use log::info;
use env_logger;
use regex::Regex;
use std::collections::{HashMap, HashSet};

#[derive(Debug)]
struct Device {
    registers: [i32; 4],
}

impl Device {
    fn new(registers: [i32; 4]) -> Device {
        Device { registers }
    }

    // addr (add register) stores into register C the result of adding register A and register B.
    fn addr(&mut self, a: i32, b: i32, c: i32) {
        self.registers[c as usize] = self.registers[a as usize] + self.registers[b as usize];
    }

    // addi (add immediate) stores into register C the result of adding register A and value B.
    fn addi(&mut self, a: i32, b: i32, c: i32) {
        self.registers[c as usize] = self.registers[a as usize] + b;
    }

    // mulr (multiply register) stores into register C the result of multiplying register A and register B.
    fn mulr(&mut self, a: i32, b: i32, c: i32) {
        self.registers[c as usize] = self.registers[a as usize] * self.registers[b as usize];
    }

    // muli (multiply immediate) stores into register C the result of multiplying register A and value B.
    fn muli(&mut self, a: i32, b: i32, c: i32) {
        self.registers[c as usize] = self.registers[a as usize] * b;
    }

    // banr (bitwise AND register) stores into register C the result of the bitwise AND of register A and register B.
    fn banr(&mut self, a: i32, b: i32, c: i32) {
        self.registers[c as usize] = self.registers[a as usize] & self.registers[b as usize];
    }

    // bani (bitwise AND immediate) stores into register C the result of the bitwise AND of register A and value B.
    fn bani(&mut self, a: i32, b: i32, c: i32) {
        self.registers[c as usize] = self.registers[a as usize] & b;
    }

    // borr (bitwise OR register) stores into register C the result of the bitwise OR of register A and register B.
    fn borr(&mut self, a: i32, b: i32, c: i32) {
        self.registers[c as usize] = self.registers[a as usize] | self.registers[b as usize];
    }

    // bori (bitwise OR immediate) stores into register C the result of the bitwise OR of register A and value B.
    fn bori(&mut self, a: i32, b: i32, c: i32) {
        self.registers[c as usize] = self.registers[a as usize] | b;
    }

    // setr (set register) copies the contents of register A into register C. (Input B is ignored.)
    fn setr(&mut self, a: i32, _b: i32, c: i32) {
        self.registers[c as usize] = self.registers[a as usize];
    }

    // seti (set immediate) stores value A into register C. (Input B is ignored.)
    fn seti(&mut self, a: i32, _b: i32, c: i32) {
        self.registers[c as usize] = a;
    }

    // gtir (greater - than immediate/ register) sets register C to 1 if value A is greater than register B. Otherwise, register C is set to 0.
    fn gtir(&mut self, a: i32, b: i32, c: i32) {
        self.registers[c as usize] = if a > self.registers[b as usize] { 1 } else { 0 };
    }

    // gtri (greater - than register / immediate) sets register C to 1 if register A is greater than value B. Otherwise, register C is set to 0.
    fn gtri(&mut self, a: i32, b: i32, c: i32) {
        self.registers[c as usize] = if self.registers[a as usize] > b { 1 } else { 0 };
    }

    // gtrr (greater -than register / register) sets register C to 1 if register A is greater than register B. Otherwise, register C is set to 0.
    fn gtrr(&mut self, a: i32, b: i32, c: i32) {
        self.registers[c as usize] = if self.registers[a as usize] > self.registers[b as usize] { 1 } else { 0 };
    }

    // eqir (equal immediate / register) sets register C to 1 if value A is equal to register B.Otherwise, register C is set to 0.
    fn eqir(&mut self, a: i32, b: i32, c: i32) {
        self.registers[c as usize] = if a == self.registers[b as usize] { 1 } else { 0 };
    }

    // eqri (equal register / immediate) sets register C to 1 if register A is equal to value B. Otherwise, register C is set to 0.
    fn eqri(&mut self, a: i32, b: i32, c: i32) {
        self.registers[c as usize] = if self.registers[a as usize] == b { 1 } else { 0 };
    }

    // eqrr (equal register / register) sets register C to 1 if register A is equal to register B.Otherwise, register C is set to 0.
    fn eqrr(&mut self, a: i32, b: i32, c: i32) {
        self.registers[c as usize] = if self.registers[a as usize] == self.registers[b as usize] { 1 } else { 0 };
    }

}

fn part1(buffer: &String) {
    // capture input, which looks like:
    //    Before: [3, 0, 1, 3]
    //    15 2 1 3
    //    After:  [3, 0, 1, 1]
    let re = Regex::new(r"(?x)
        Before:\s+\[(\d+),\s*(\d+),\s*(\d+),\s*(\d+)\]\n
        (\d+)\s+(\d+)\s+(\d+)\s+(\d+)\n
        After: \s+\[(\d+),\s*(\d+),\s*(\d+),\s*(\d+)\]
        ").expect("regex error");
    let mut sample_map : HashMap<i32, HashSet<String>> = HashMap::new();
    let mut three_or_more_count = 0;

    for cap in re.captures_iter(&buffer) {
        let mut numbers = Vec::new();
        for i in 1..cap.len() {
            numbers.push(cap[i].parse::<i32>().expect("could not parse number"));
        }
        let before = [numbers[0], numbers[1], numbers[2], numbers[3]];
        let (opcode, a, b, c) = (numbers[4], numbers[5], numbers[6], numbers[7]);
        let after = [numbers[8], numbers[9], numbers[10], numbers[11]];

        let mut match_count = 0;
        let mut device = Device::new(before);
        device.addr(a, b, c);
        if device.registers == after {
            let entry = sample_map.entry(opcode).or_insert(HashSet::new());
            entry.insert("addr".to_string());
            match_count += 1;
        }

        let mut device = Device::new(before);
        device.addi(a, b, c);
        if device.registers == after {
            let entry = sample_map.entry(opcode).or_insert(HashSet::new());
            entry.insert("addi".to_string());
            match_count += 1;
        }

        let mut device = Device::new(before);
        device.mulr(a, b, c);
        if device.registers == after {
            let entry = sample_map.entry(opcode).or_insert(HashSet::new());
            entry.insert("mulr".to_string());
            match_count += 1;
        }

        let mut device = Device::new(before);
        device.muli(a, b, c);
        if device.registers == after {
            let entry = sample_map.entry(opcode).or_insert(HashSet::new());
            entry.insert("muli".to_string());
            match_count += 1;
        }

        let mut device = Device::new(before);
        device.banr(a, b, c);
        if device.registers == after {
            let entry = sample_map.entry(opcode).or_insert(HashSet::new());
            entry.insert("banr".to_string());
            match_count += 1;
        }

        let mut device = Device::new(before);
        device.bani(a, b, c);
        if device.registers == after {
            let entry = sample_map.entry(opcode).or_insert(HashSet::new());
            entry.insert("bani".to_string());
            match_count += 1;
        }

        let mut device = Device::new(before);
        device.borr(a, b, c);
        if device.registers == after {
            let entry = sample_map.entry(opcode).or_insert(HashSet::new());
            entry.insert("borr".to_string());
            match_count += 1;
        }

        let mut device = Device::new(before);
        device.bori(a, b, c);
        if device.registers == after {
            let entry = sample_map.entry(opcode).or_insert(HashSet::new());
            entry.insert("bori".to_string());
            match_count += 1;
        }

        let mut device = Device::new(before);
        device.setr(a, b, c);
        if device.registers == after {
            let entry = sample_map.entry(opcode).or_insert(HashSet::new());
            entry.insert("setr".to_string());
            match_count += 1;
        }

        let mut device = Device::new(before);
        device.seti(a, b, c);
        if device.registers == after {
            let entry = sample_map.entry(opcode).or_insert(HashSet::new());
            entry.insert("seti".to_string());
            match_count += 1;
        }

        let mut device = Device::new(before);
        device.gtir(a, b, c);
        if device.registers == after {
            let entry = sample_map.entry(opcode).or_insert(HashSet::new());
            entry.insert("gtir".to_string());
            match_count += 1;
        }

        let mut device = Device::new(before);
        device.gtri(a, b, c);
        if device.registers == after {
            let entry = sample_map.entry(opcode).or_insert(HashSet::new());
            entry.insert("gtri".to_string());
            match_count += 1;
        }

        let mut device = Device::new(before);
        device.gtrr(a, b, c);
        if device.registers == after {
            let entry = sample_map.entry(opcode).or_insert(HashSet::new());
            entry.insert("gtrr".to_string());
            match_count += 1;
        }

        let mut device = Device::new(before);
        device.eqir(a, b, c);
        if device.registers == after {
            let entry = sample_map.entry(opcode).or_insert(HashSet::new());
            entry.insert("eqir".to_string());
            match_count += 1;
        }

        let mut device = Device::new(before);
        device.eqri(a, b, c);
        if device.registers == after {
            let entry = sample_map.entry(opcode).or_insert(HashSet::new());
            entry.insert("eqri".to_string());
            match_count += 1;
        }

        let mut device = Device::new(before);
        device.eqrr(a, b, c);
        if device.registers == after {
            let entry = sample_map.entry(opcode).or_insert(HashSet::new());
            entry.insert("eqrr".to_string());
            match_count += 1;
        }

        if match_count >= 3 {
            three_or_more_count += 1;
        }
    }

    info!("Number of samples matching three or more ops: {}", three_or_more_count);

    let mut opcode_map : HashMap<String, i32> = HashMap::new();
    while opcode_map.len() < 16 {
        for (opcode, ops) in &sample_map {
            let known_ops : HashSet<String> = opcode_map.keys().into_iter().cloned().collect();
            let new_ops : HashSet<String> = ops.difference(&known_ops).cloned().collect();
            if new_ops.len() == 1 {
                let op = new_ops.iter().nth(0).unwrap().clone();
                opcode_map.insert(op, *opcode);
            }
        }
    }

    for (op, opcode) in &opcode_map {
        println!("{} => device.{}(a, b, c),", opcode, op);
    }

}

fn part2(buffer: &String) {
    let mut device = Device::new([0,0,0,0]);
    for line in buffer.lines() {
        let parts = line.split_whitespace().into_iter()
            .map(|num| num.trim().parse::<i32>().expect("could not parse number"))
            .collect::<Vec<i32>>();
        let (opcode, a, b, c) = (parts[0], parts[1], parts[2], parts[3]);

        match opcode {
            0 => device.banr(a, b, c),
            1 => device.muli(a, b, c),
            2 => device.bori(a, b, c),
            3 => device.setr(a, b, c),
            4 => device.addi(a, b, c),
            5 => device.eqrr(a, b, c),
            6 => device.gtri(a, b, c),
            7 => device.gtir(a, b, c),
            8 => device.borr(a, b, c),
            9 => device.eqri(a, b, c),
            10 => device.bani(a, b, c),
            11 => device.addr(a, b, c),
            12 => device.eqir(a, b, c),
            13 => device.mulr(a, b, c),
            14 => device.seti(a, b, c),
            15 => device.gtrr(a, b, c),
            _ => (),
        }
    }

    info!("Register 0: {}", device.registers[0]);
}

fn main() {
    env_logger::init();

    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer).expect("Error reading from stdin");

//    part1(&buffer);
    part2(&buffer);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_addr() {
        let mut device = Device { registers: [3, 1, 4, 1] };
        device.addr(3, 2, 1);
        assert_eq!(device.registers[1], 5);
    }

    #[test]
    fn test_addi() {
        let mut device = Device { registers: [3, 1, 4, 1] };
        device.addi(3, 2, 1);
        assert_eq!(device.registers[1], 3);
    }

    #[test]
    fn test_mulr() {
        let mut device = Device { registers: [3, 1, 4, 1] };
        device.mulr(0, 2, 1);
        assert_eq!(device.registers[1], 12);
    }

    #[test]
    fn test_muli() {
        let mut device = Device { registers: [3, 1, 4, 1] };
        device.muli(0, 2, 1);
        assert_eq!(device.registers[1], 6);
    }

    #[test]
    fn test_banr() {
        let mut device = Device { registers: [3, 1, 4, 2] };
        device.banr(3, 2, 1);
        assert_eq!(device.registers[1], 0);
    }

    #[test]
    fn test_bani() {
        let mut device = Device { registers: [3, 1, 4, 2] };
        device.bani(3, 2, 1);
        assert_eq!(device.registers[1], 2);
    }

    #[test]
    fn test_borr() {
        let mut device = Device { registers: [3, 1, 4, 2] };
        device.borr(3, 2, 1);
        assert_eq!(device.registers[1], 6);
    }

    #[test]
    fn test_bori() {
        let mut device = Device { registers: [3, 1, 4, 2] };
        device.bori(3, 2, 1);
        assert_eq!(device.registers[1], 2);
    }

    #[test]
    fn test_setr() {
        let mut device = Device { registers: [3, 1, 4, 2] };
        device.setr(3, 0, 1);
        assert_eq!(device.registers[1], 2);
    }

    #[test]
    fn test_seti() {
        let mut device = Device { registers: [3, 1, 4, 2] };
        device.seti(3, 0, 1);
        assert_eq!(device.registers[1], 3);
    }

    #[test]
    fn test_gtir() {
        let mut device = Device { registers: [3, 1, 4, 2] };
        device.gtir(3, 0, 1);
        assert_eq!(device.registers[1], 0);
        device.gtir(4, 0, 1);
        assert_eq!(device.registers[1], 1);
    }

    #[test]
    fn test_gtri() {
        let mut device = Device { registers: [3, 1, 4, 2] };
        device.gtri(3, 2, 1);
        assert_eq!(device.registers[1], 0);
        device.gtri(2, 2, 1);
        assert_eq!(device.registers[1], 1);
    }

    #[test]
    fn test_gtrr() {
        let mut device = Device { registers: [3, 1, 4, 2] };
        device.gtrr(3, 0, 1);
        assert_eq!(device.registers[1], 0);
        device.gtrr(2, 0, 1);
        assert_eq!(device.registers[1], 1);
    }

    #[test]
    fn test_eqir() {
        let mut device = Device { registers: [3, 1, 4, 2] };
        device.eqir(3, 0, 1);
        assert_eq!(device.registers[1], 1);
        device.eqir(4, 0, 1);
        assert_eq!(device.registers[1], 0);
    }

    #[test]
    fn test_eqri() {
        let mut device = Device { registers: [3, 1, 4, 2] };
        device.eqri(3, 2, 1);
        assert_eq!(device.registers[1], 1);
        device.eqri(2, 2, 1);
        assert_eq!(device.registers[1], 0);
    }

    #[test]
    fn test_eqrr() {
        let mut device = Device { registers: [3, 1, 4, 1] };
        device.eqrr(3, 1, 1);
        assert_eq!(device.registers[1], 1);
        device.eqrr(1, 2, 1);
        assert_eq!(device.registers[1], 0);
    }

}

