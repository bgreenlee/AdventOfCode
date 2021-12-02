use std::io::{self, Read};

fn main() -> io::Result<()>  {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer)?;

    let numbers = buffer.lines()
        .filter_map(|n| n.parse().ok())
        .collect::<Vec<i32>>();
    
    let count1 = numbers.windows(2)
        .fold(0, |acc, w| if w[1] > w[0] { acc + 1 } else { acc });                    

    println!("Part 1: {}", count1);

    let count2 = numbers.windows(3)
        .map(|w| w.iter().sum::<i32>())
        .collect::<Vec<i32>>()
        .windows(2)
        .fold(0, |acc, w| if w[1] > w[0] { acc + 1 } else { acc });                    

    println!("Part 2: {}", count2);

    Ok(())
}