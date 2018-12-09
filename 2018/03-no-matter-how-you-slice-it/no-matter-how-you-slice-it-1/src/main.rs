use std::io::{self, Read};

fn main() -> io::Result<()> {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer)?;
    let ids: Vec<&str> = buffer.lines().collect();

//    #1 @ 1,3: 4x4
//    #2 @ 3,1: 4x4
//    #3 @ 5,5: 2x2
    for id in ids {
        let parts = id.split(|c:char| !c.is_numeric())
    }
    Ok(())
}