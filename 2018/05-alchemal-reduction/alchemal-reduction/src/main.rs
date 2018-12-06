use std::io::{self, Read};

fn react_polymer(mut input_chars : Vec<char>) -> usize {
    let mut output_chars = Vec::new();
    let mut i : usize = 0;
    while input_chars.len() > 1 {
        while i < input_chars.len() - 1 {
            if input_chars[i] == input_chars[i + 1] ||
                (input_chars[i] != input_chars[i + 1].to_ascii_uppercase() &&
                    input_chars[i] != input_chars[i + 1].to_ascii_lowercase()) {
                output_chars.push(input_chars[i]);
                i += 1;
                if i == input_chars.len() - 1 {
                    output_chars.push(input_chars[i]);
                    i += 1;
                }
            } else {
                i += 2;
            }
        }
        if output_chars.len() == input_chars.len() {
            break;
        } else {
            input_chars = output_chars.clone();
            output_chars = Vec::new();
            i = 0;
        }
    }

    output_chars.len()
}
fn main() -> io::Result<()>  {
    let mut input = String::new();
    io::stdin().read_to_string(&mut input)?;
    let input_chars : Vec<char> = input.chars().collect();

    let result = react_polymer(input_chars.clone());
    println!("Initial polymer reduction: {}", result);

    static ASCII_LOWER: [char; 26] = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i',
        'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r',
        's', 't', 'u', 'v', 'w', 'x', 'y', 'z'];

    let mut min_result = 99999999;
    for c in ASCII_LOWER.iter() {
        let filtered_input = input_chars.iter().filter(|i| **i != *c && **i != (*c).to_ascii_uppercase()).cloned().collect();
        let result = react_polymer(filtered_input);
        println!("{} => {}", c, result);
        if result < min_result {
            min_result = result;
        }

    }

    println!("{}", min_result);

    Ok(())
}
