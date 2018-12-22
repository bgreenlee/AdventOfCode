use std::io::{self, Read};

#[derive(Debug)]
struct Device<'a> {
    registers: [usize; 6],
    ip_register: usize,
    program: Vec<(&'a str, [usize; 3])>,
}

impl<'a> Device<'a> {
    fn new(registers: [usize; 6], ip_register: usize) -> Device<'a> {
        Device { registers, ip_register, program: Vec::new() }
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

    fn execute(&mut self) {
        let mut ip = 0;
        for _ in 0..100 {
//        while ip < self.program.len() {
            self.registers[self.ip_register] = ip;
            let (instr, params) = &self.program[ip];
            let (a, b, c) = (params[0], params[1], params[2]);
            println!("{}: {:?} {} {:?}", ip, self.registers, instr, params);
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
        }
    }
}

fn main() {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer).expect("Error reading from stdin");
    // part 1 ended with [1536, 988, 256, 988, 987, 1]
    let mut device = Device::new([1,0,0,0,0,0], 0);
    for line in buffer.lines() {
        let mut split = line.split_whitespace();
        let instr = split.nth(0).expect("could not parse instruction");
        let parts = split.into_iter()
            .map(|num| num.trim().parse::<usize>().expect("could not parse number"))
            .collect::<Vec<usize>>();

        match instr {
            "#ip" => device.ip_register = parts[0],
            instr => device.program.push((instr, [parts[0], parts[1], parts[2]]))
        }
    }
//    println!("{:?}", device);
    device.execute();
    println!("Registers: {:?}", device.registers);
}

