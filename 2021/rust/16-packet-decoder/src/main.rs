use std::io::{self, Read};
use std::collections::VecDeque;

struct Packet {
    version: u8,
    value: u64,
    subpackets: Vec<Packet>,
}

impl Packet {
    fn new(bits: &mut VecDeque<char>) -> Packet {
        let version = Self::pop_value(bits, 3) as u8;
        let type_id = Self::pop_value(bits, 3) as u8;
        let value;
        let mut subpackets: Vec<Packet> = Vec::new();

        if type_id == 4 {
            value = Self::parse_literal(bits)
        } else {
            subpackets = Self::parse_operator(bits);
            let mut values = subpackets.iter().map(|p| p.value);
            value = match type_id {
                0 => values.sum(),
                1 => values.product(),
                2 => values.min().unwrap(),
                3 => values.max().unwrap(),
                5 => if values.next().unwrap() > values.next().unwrap() { 1 } else { 0 },
                6 => if values.next().unwrap() < values.next().unwrap() { 1 } else { 0 },
                7 => if values.next().unwrap() == values.next().unwrap() { 1 } else { 0 },
                _ => 0,
            }
        }

        Packet { version, value, subpackets }
    }

    fn packets_from_hexstr(hexstr: &str) -> Vec<Packet> {
        let mut bits = Self::hex_to_binary(hexstr);
        Packet::packets_from_bits(&mut bits)
    }

    fn packets_from_bits(bits: &mut VecDeque<char>) -> Vec<Packet> {
        let mut packets: Vec<Packet> = Vec::new();

        while bits.len() > 6 {
            let packet = Packet::new(bits);
            packets.push(packet);
        }

        packets
    }

    fn parse_literal(bits: &mut VecDeque<char>) -> u64 {
        let mut val_bits: Vec<char> = Vec::new();
        loop {
            let flag = bits.drain(0..1).collect::<Vec<char>>()[0];
            let new_bits = &mut bits.drain(0..4).collect::<Vec<char>>();
            val_bits.append(new_bits);
            
            if flag == '0' {
                break;
            }
        }
        let bitstr = &val_bits.iter().collect::<String>();
        u64::from_str_radix(bitstr, 2).unwrap()
    }

    fn parse_operator(bits: &mut VecDeque<char>) -> Vec<Packet> {
        let mut subpackets: Vec<Packet>;
        let length_type_id = bits.pop_front().unwrap();
        if length_type_id == '0' {
            let total_length = Self::pop_value(bits, 15) as usize;
            let mut subpacket_bits = bits.drain(0..total_length).collect::<VecDeque<char>>();
            subpackets = Packet::packets_from_bits(&mut subpacket_bits);
        } else {
            let num_subpackets = Self::pop_value(bits, 11);
            subpackets = Vec::new();
            for _ in 0..num_subpackets {
                subpackets.push(Packet::new(bits));
            }
        }
        subpackets
    }

    fn pop_value(bits: &mut VecDeque<char>, num_bits: usize) -> u64 {
        let strval = bits.drain(0..num_bits).collect::<String>();
        u64::from_str_radix(&strval, 2).unwrap()
    }

    fn hex_to_binary(hexstr: &str) -> VecDeque<char> {
        let mut binary: VecDeque<char> = VecDeque::new();
        for c in hexstr.chars() {
            let binstr = format!("{:04b}", c.to_digit(16).unwrap());
            binary.append(&mut VecDeque::from_iter(binstr.chars()));
        }
        binary
    }

    fn version_sum(&self) -> u64 {
        let mut sum = self.version as u64;
        for subpacket in &self.subpackets {
            sum += subpacket.version_sum();
        }
        sum
    }
}

fn main() {
    let mut buffer = String::new();
    io::stdin()
        .read_to_string(&mut buffer)
        .expect("Error reading from stdin");
    let lines: Vec<&str> = buffer.lines().collect();
    let input = lines[0];

    let packets = Packet::packets_from_hexstr(input);
    let total: u64 = packets.iter().map(|p| p.version_sum()).sum();
    println!("Part 1: {}", total);
    println!("Part 2: {}", packets[0].value);

}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn hex_to_binary() {
        assert_eq!(
            Packet::hex_to_binary("42"),
            ['0','1','0','0','0','0','1','0']
        );
        assert_eq!(
            Packet::hex_to_binary("D2FE28").iter().collect::<String>(),
            "110100101111111000101000"
        );
    }

    #[test]
    fn literal_packet() {
        let mut bits = Packet::hex_to_binary("D2FE28");
        let packet = Packet::new(&mut bits);
        assert_eq!(packet.value, 2021);
    }
}