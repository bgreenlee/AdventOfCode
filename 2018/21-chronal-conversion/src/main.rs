use std::io::{self, Read};
use std::env;
use std::usize;
use std::collections::HashSet;

#[derive(Debug)]
struct Device<'a> {
    registers: [usize; 6],
    ip_register: usize,
    program: Vec<(&'a str, [usize; 3])>,
    cycles: usize,
}

impl<'a> Device<'a> {
    fn new() -> Device<'a> {
        Device { registers: [0,0,0,0,0,0], ip_register: 0, program: Vec::new(), cycles: 0 }
    }

    // addr (add register) stores into register C the result of adding register A and register B.
    fn addr(&mut self, a: usize, b: usize, c: usize) {
        self.registers[c] = self.registers[a] + self.registers[b];
    }

    // addi (add immediate) stores into register C the result of adding register A and value B.
    fn addi(&mut self, a: usize, b: usize, c: usize) {
        self.registers[c] = self.registers[a] + b;
    }

    // mulr (multiply register) stores into register C the result of multiplying register A and register B.
    fn mulr(&mut self, a: usize, b: usize, c: usize) {
        self.registers[c] = self.registers[a] * self.registers[b];
    }

    // muli (multiply immediate) stores into register C the result of multiplying register A and value B.
    fn muli(&mut self, a: usize, b: usize, c: usize) {
        self.registers[c] = self.registers[a] * b;
    }

    // banr (bitwise AND register) stores into register C the result of the bitwise AND of register A and register B.
    fn banr(&mut self, a: usize, b: usize, c: usize) {
        self.registers[c] = self.registers[a] & self.registers[b];
    }

    // bani (bitwise AND immediate) stores into register C the result of the bitwise AND of register A and value B.
    fn bani(&mut self, a: usize, b: usize, c: usize) {
        self.registers[c] = self.registers[a] & b;
    }

    // borr (bitwise OR register) stores into register C the result of the bitwise OR of register A and register B.
    fn borr(&mut self, a: usize, b: usize, c: usize) {
        self.registers[c] = self.registers[a] | self.registers[b];
    }

    // bori (bitwise OR immediate) stores into register C the result of the bitwise OR of register A and value B.
    fn bori(&mut self, a: usize, b: usize, c: usize) {
        self.registers[c] = self.registers[a] | b;
    }

    // setr (set register) copies the contents of register A into register C. (Input B is ignored.)
    fn setr(&mut self, a: usize, _b: usize, c: usize) {
        self.registers[c] = self.registers[a];
    }

    // seti (set immediate) stores value A into register C. (Input B is ignored.)
    fn seti(&mut self, a: usize, _b: usize, c: usize) {
        self.registers[c] = a;
    }

    // gtir (greater - than immediate/ register) sets register C to 1 if value A is greater than register B. Otherwise, register C is set to 0.
    fn gtir(&mut self, a: usize, b: usize, c: usize) {
        self.registers[c] = if a > self.registers[b] { 1 } else { 0 };
    }

    // gtri (greater than register / immediate) sets register C to 1 if register A is greater than value B. Otherwise, register C is set to 0.
    fn gtri(&mut self, a: usize, b: usize, c: usize) {
        self.registers[c] = if self.registers[a] > b { 1 } else { 0 };
    }

    // gtrr (greater than register / register) sets register C to 1 if register A is greater than register B. Otherwise, register C is set to 0.
    fn gtrr(&mut self, a: usize, b: usize, c: usize) {
        self.registers[c] = if self.registers[a] > self.registers[b] { 1 } else { 0 };
    }

    // eqir (equal immediate / register) sets register C to 1 if value A is equal to register B.Otherwise, register C is set to 0.
    fn eqir(&mut self, a: usize, b: usize, c: usize) {
        self.registers[c] = if a == self.registers[b] { 1 } else { 0 };
    }

    // eqri (equal register / immediate) sets register C to 1 if register A is equal to value B. Otherwise, register C is set to 0.
    fn eqri(&mut self, a: usize, b: usize, c: usize) {
        self.registers[c] = if self.registers[a] == b { 1 } else { 0 };
    }

    // eqrr (equal register / register) sets register C to 1 if register A is equal to register B. Otherwise, register C is set to 0.
    fn eqrr(&mut self, a: usize, b: usize, c: usize) {
        self.registers[c] = if self.registers[a] == self.registers[b] { 1 } else { 0 };
    }

    fn load(&mut self, program: &'a str) {
        for line in program.lines() {
            let mut split = line.split_whitespace();
            let instr = split.nth(0).expect("could not parse instruction");
            let parts = split.into_iter()
                .map(|num| num.trim().parse::<usize>().expect("could not parse number"))
                .collect::<Vec<usize>>();

            match instr {
                "#ip" => self.ip_register = parts[0],
                instr => self.program.push((instr, [parts[0], parts[1], parts[2]]))
            }
        }
    }

//    fn reset(&mut self) {
//        self.registers = [0,0,0,0,0,0];
//        self.cycles = 0;
//    }

    fn execute(&mut self, mut num_cycles: usize) {
        let mut seen = HashSet::new();
        let mut ip : usize = 0;
        if num_cycles == 0 {
            num_cycles = usize::MAX;
        }
        for _ in 0..=num_cycles {
            if ip >= self.program.len() {
                break;
            }
            self.registers[self.ip_register] = ip;
            let (instr, params) = &self.program[ip];
            let (a, b, c) = (params[0], params[1], params[2]);
            if ip == 28 {
                // part 1 - we want to stop on the first value that gets us here
//                println!("{}", self.registers[5]);
//                break;
                // part 2 - we want to wait until we are getting no more new values; eventually
                // it will start looping and stop. The last number printed is our answer.
                if !seen.contains(&self.registers[5]) {
                    println!("{}", self.registers[5]);
                    seen.insert(self.registers[5]);
                }
            }
            //println!("[{}] {}: {:?} {} {:?}", self.cycles, ip, self.registers, instr, params);
            match *instr {
                "banr" => self.banr(a, b, c),
                "muli" => self.muli(a, b, c),
                "bori" => self.bori(a, b, c),
                "setr" => self.setr(a, b, c),
                "addi" => self.addi(a, b, c),
                "eqrr" => self.eqrr(a, b, c),
                "gtri" => self.gtri(a, b, c),
                "gtir" => self.gtir(a, b, c),
                "borr" => self.borr(a, b, c),
                "eqri" => self.eqri(a, b, c),
                "bani" => self.bani(a, b, c),
                "addr" => self.addr(a, b, c),
                "eqir" => self.eqir(a, b, c),
                "mulr" => self.mulr(a, b, c),
                "seti" => self.seti(a, b, c),
                "gtrr" => self.gtrr(a, b, c),
                _ => break,
            };
            ip = self.registers[self.ip_register];
            ip += 1;
            self.cycles += 1;
        }
    }
}

fn main() {
    let mut reg_0: usize = 0;
    if env::args().len() > 1 {
        reg_0 = env::args().nth(1).unwrap_or("0".to_string()).parse::<usize>().unwrap();
    }

    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer).expect("Error reading from stdin");

    let mut device = Device::new();
    device.load(&buffer);
    device.registers[0] = reg_0;

    let num_cycles = usize::MAX;
    device.execute(num_cycles);
    if device.cycles < num_cycles {
        println!("Stopped in {} cycles", device.cycles);
    }
}

