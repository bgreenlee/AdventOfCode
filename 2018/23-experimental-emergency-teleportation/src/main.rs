#[macro_use] extern crate lazy_static;
use std::io::{self, Read};
use regex::Regex;

#[derive(Debug,Eq,PartialEq)]
struct NanoBot {
    x: i32,
    y: i32,
    z: i32,
    r: i32,
}

impl NanoBot {
    fn from_string(input: &str) -> NanoBot {
        lazy_static! {
            // pos=<0,0,0>, r=4
            static ref RE: Regex = Regex::new(r"pos=<(-?\d+),(-?\d+),(-?\d+)>, r=(\d+)").unwrap();
        }
        let caps = RE.captures(input).unwrap().iter()
            .skip(1)
            .map(|c| c.unwrap().as_str().parse::<i32>().unwrap())
            .collect::<Vec<_>>();
        NanoBot { x: caps[0], y: caps[1], z: caps[2], r: caps[3]}
    }

    fn distance(&self, other: &NanoBot) -> i32 {
        ((self.x - other.x).abs() +
            (self.y - other.y).abs() +
            (self.z - other.z).abs())
    }

    fn in_range(&self, other: &NanoBot) -> bool {
        self.distance(other) <= self.r
    }

}

fn find_max_overlap(starts: &mut Vec<i32>, ends: &mut Vec<i32>) -> ((i32, i32), i32) {
    starts.sort();
    ends.sort();

    let mut max_overlap = 0;
    let mut max_overlap_range = (0,0);
    let mut current_overlap = 0;

    let mut i = 0;
    let mut j = 0;
    while i < starts.len() && j < ends.len() {
        if starts[i] <= ends[j] {
            current_overlap += 1;
            if current_overlap > max_overlap {
                max_overlap = current_overlap;
                max_overlap_range = (starts[i], ends[j]);
            }
            i += 1;
        } else {
            current_overlap -= 1;
            j += 1;
        }
    }

    (max_overlap_range, max_overlap)
}

fn num_bots_in_range(bots: &Vec<NanoBot>, coord: (i32,i32,i32)) -> usize {
    bots.iter().filter(|b| {
        let distance = (b.x - coord.0).abs() +
                       (b.y - coord.1).abs() +
                       (b.z - coord.2).abs();
        distance <= b.r
    }).count()
}

fn main() {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer).expect("Error reading from stdin");

    let mut bots = buffer.lines().map(|l| NanoBot::from_string(l)).collect::<Vec<_>>();
    bots.sort_by(|a,b| a.r.cmp(&b.r));
    let strongest_bot = bots.last().unwrap();
    println!("Strongest: {:?}", strongest_bot);
    let in_range = bots.iter()
        .filter(|b| strongest_bot.in_range(b))
        .count();
    println!("In range: {}", in_range);

    let mut starts: Vec<i32> = bots.iter().map(|b| b.x - b.r).collect::<Vec<_>>();
    let mut ends: Vec<i32> = bots.iter().map(|b| b.x + b.r).collect::<Vec<_>>();
    let (x_max_overlap_range, max_overlap) = find_max_overlap(&mut starts, &mut ends);

    println!("x max overlap: {}", max_overlap);
    println!("x max range: {:?}", x_max_overlap_range);

    let mut starts: Vec<i32> = bots.iter().map(|b| b.y - b.r).collect::<Vec<_>>();
    let mut ends: Vec<i32> = bots.iter().map(|b| b.y + b.r).collect::<Vec<_>>();
    let (y_max_overlap_range, max_overlap) = find_max_overlap(&mut starts, &mut ends);

    println!("y max overlap: {}", max_overlap);
    println!("y max range: {:?}", y_max_overlap_range);

    let mut starts: Vec<i32> = bots.iter().map(|b| b.z - b.r).collect::<Vec<_>>();
    let mut ends: Vec<i32> = bots.iter().map(|b| b.z + b.r).collect::<Vec<_>>();
    let (z_max_overlap_range, max_overlap) = find_max_overlap(&mut starts, &mut ends);

    println!("z max overlap: {}", max_overlap);
    println!("z max range: {:?}", z_max_overlap_range);

    let mut max_bots = 0;
    let mut max_bots_point = (0,0,0);

    let z = z_max_overlap_range.0;
    for x in x_max_overlap_range.0..=x_max_overlap_range.1 {
        for y in y_max_overlap_range.0..=y_max_overlap_range.1 {
//            for z in z_max_overlap_range.0..=z_max_overlap_range.1 {
                let point = (x,y,z);
                let num_bots = num_bots_in_range(&bots, point);
                if num_bots > max_bots {
                    max_bots = num_bots;
                    max_bots_point = point;
                    println!("{} @ {:?}", max_bots, max_bots_point);
                }
//            }
        }
    }
    println!("distance: {}", max_bots_point.0.abs() + max_bots_point.1.abs() + max_bots_point.2.abs());
//    let x = x_max_overlap_range.0 + (x_max_overlap_range.1 - x_max_overlap_range.0) / 2;
//    let y = y_max_overlap_range.0 + (y_max_overlap_range.1 - y_max_overlap_range.0) / 2;
//    let z = z_max_overlap_range.0 + (z_max_overlap_range.1 - z_max_overlap_range.0) / 2;
//
//    println!("({},{},{})", x, y, z);
//    println!("distance: {}", x.abs() + y.abs() + z.abs());
//
//
//    let num_bots = num_bots_in_range(&bots, (x_max_overlap_range.0, y_max_overlap_range.0, z_max_overlap_range.0));
//    println!("num at start: {}", num_bots);
//    let num_bots = num_bots_in_range(&bots, (x,y,z));
//    println!("num at mid: {}", num_bots);
//    let num_bots = num_bots_in_range(&bots, (x_max_overlap_range.1, y_max_overlap_range.1, z_max_overlap_range.1));
//    println!("num at end: {}", num_bots);
//    let num_bots = num_bots_in_range(&bots, (12,12,12));
//    println!("num at answer: {}", num_bots);

//    let mut overlap_starts = vec![x_max_overlap_range.0, y_max_overlap_range.0, z_max_overlap_range.0];
//    let mut overlap_ends = vec![x_max_overlap_range.1, y_max_overlap_range.1, z_max_overlap_range.1];
//    let (total_max_overlap_range, total_max_overlap) = find_max_overlap(&mut overlap_starts, &mut overlap_ends);
//
//    println!("total max overlap: {}", total_max_overlap);
//    println!("total max range: {:?}", total_max_overlap_range);

}
