use std::io::{self, Read};
use std::collections::HashSet;

type Point = (i32, i32);

fn main() {
    let mut buffer = String::new();
    io::stdin()
        .read_to_string(&mut buffer)
        .expect("Error reading from stdin");
    let lines: Vec<&str> = buffer.lines().collect();

    let algo: Vec<char> = lines[0].chars().collect();

    let mut input_image: HashSet<Point> = HashSet::new();
    for i in 2..lines.len() {
        let line = lines[i];
        for (x, c) in line.char_indices() {
            if c == '#' {
                input_image.insert((x as i32, (i-2) as i32));
            }
        }
    }

    let mut background_lit = false;
    for _ in 0..50 {
        enhance(&mut input_image, &mut background_lit, &algo);
    }
    // display(&input_image);
    println!("{}", input_image.iter().count());
}

fn enhance(image: &mut HashSet<Point>, background_lit: &mut bool, algo: &Vec<char>) {
    let ((minx, miny), (maxx, maxy)) = get_bounds(image);
    let mut new_image: HashSet<Point> = HashSet::new();
    for y in miny-1..=maxy+1 {
        for x in minx-1..=maxx+1 {
            let mut algo_idx = 0;
            for offset_y in y-1..=y+1 {
                for offset_x in x-1..=x+1 {
                    algo_idx <<= 1;
                    // if the background is lit and we're looking outside our image, consider the pixel on
                    if *background_lit && !((minx..=maxx).contains(&offset_x) && (miny..=maxy).contains(&offset_y)) ||
                        image.contains(&(offset_x, offset_y))
                    {
                        algo_idx |= 1;
                    }
                }
            }
            if algo[algo_idx] == '#' {
                new_image.insert((x,y));
            }
        }
    }
    // if the 0 element of our algorithm is set, the background will alternate between dark and light with each iteration
    if algo[0] == '#' {
        *background_lit = !*background_lit;
    }
    *image = new_image;
}

#[allow(dead_code)]
fn display(image: &HashSet<Point>) {
    let ((minx, miny), (maxx, maxy)) = get_bounds(image);
    for y in miny..=maxy {
        for x in minx..=maxx {
            print!("{}", if image.contains(&(x,y)) { '#' } else { ' ' });
        }
        println!()
    }
}

// get bounds of image
// we should keep track of these separately for efficiency, but maybe later
fn get_bounds(image: &HashSet<Point>) -> (Point, Point) {
    let (mut minx, mut miny) = (i32::MAX, i32::MAX);
    let (mut maxx, mut maxy) = (i32::MIN, i32::MIN);
    for (x, y) in image.iter() {
        if *x < minx { minx = *x }
        if *x > maxx { maxx = *x }
        if *y < miny { miny = *y }
        if *y > maxy { maxy = *y }
    }
    ((minx, miny), (maxx, maxy))
}

#[allow(unused_macros)]
macro_rules! dbg {
    ($x:expr) => {
        println!("{} = {:?}",stringify!($x),$x);
    }
}