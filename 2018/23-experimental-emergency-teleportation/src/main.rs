#[macro_use] extern crate lazy_static;
use std::io::{self, Read};
use std::cmp::Ordering;
use regex::Regex;

#[derive(Debug,Copy,Clone)]
struct Point {
    x: i128,
    y: i128,
    z: i128,
}

impl Point {
    fn scalar(&self) -> i128 {
        self.x * self.y * self.z
    }
}

impl PartialEq for Point {
    fn eq(&self, other: &Point) -> bool {
        self.x == other.x && self.y == other.y && self.y == other.z
    }
}

impl Eq for Point {}


impl Ord for Point {
    fn cmp(&self, other: &Point) -> Ordering {
        self.scalar().partial_cmp(&other.scalar()).unwrap_or(Ordering::Equal)
    }
}

impl PartialOrd for Point {
    fn partial_cmp(&self, other: &Point) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

#[derive(Debug,Eq,PartialEq)]
struct Bot {
    point: Point,
    r: i128,
}

impl Bot {
    fn from_string(input: &str) -> Bot {
        lazy_static! {
            // pos=<0,0,0>, r=4
            static ref RE: Regex = Regex::new(r"pos=<(-?\d+),(-?\d+),(-?\d+)>, r=(\d+)").unwrap();
        }
        let caps = RE.captures(input).unwrap().iter()
            .skip(1)
            .map(|c| c.unwrap().as_str().parse::<i128>().unwrap())
            .collect::<Vec<_>>();
        Bot { point: Point { x: caps[0], y: caps[1], z: caps[2] }, r: caps[3]}
    }

    fn start_point(&self) -> Point {
        Point { x: self.point.x - self.r, y: self.point.y - self.r, z: self.point.z - self.r }
    }

    fn end_point(&self) -> Point {
        Point { x: self.point.x + self.r, y: self.point.y + self.r, z: self.point.z + self.r }
    }

    fn distance(&self, other: &Bot) -> i128 {
        ((self.point.x - other.point.x).abs() +
            (self.point.y - other.point.y).abs() +
            (self.point.z - other.point.z).abs())
    }

    fn in_range(&self, other: &Bot) -> bool {
        self.distance(other) <= self.r
    }

}

fn find_max_overlap(starts: &mut Vec<Point>, ends: &mut Vec<Point>) -> ((Point,Point), i128) {
    starts.sort();
    ends.sort();

    let mut max_overlap = 0;
    let mut max_overlap_range = (Point { x:0,y:0,z:0 }, Point { x:0,y:0,z:0 });
    let mut current_overlap = 0;

    let mut i = 0;
    let mut j = 0;
    while i < starts.len() && j < ends.len() {
        if starts[i].scalar() <= ends[j].scalar() {
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

//fn num_bots_in_range(bots: &Vec<Bot>, point: Point) -> usize {
//    bots.iter().filter(|b| {
//        let distance = (b.point.x - point.x).abs() +
//                       (b.point.y - point.y).abs() +
//                       (b.point.z - point.z).abs();
//        distance <= b.r
//    }).count()
//}

fn main() {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer).expect("Error reading from stdin");

    let mut bots = buffer.lines().map(|l| Bot::from_string(l)).collect::<Vec<_>>();
    bots.sort_by(|a,b| a.r.cmp(&b.r));
    let strongest_bot = bots.last().unwrap();
    println!("Strongest: {:?}", strongest_bot);
    let in_range = bots.iter()
        .filter(|b| strongest_bot.in_range(b))
        .count();
    println!("In range: {}", in_range);

    let mut starts= bots.iter().map(Bot::start_point).collect::<Vec<_>>();
    let mut ends = bots.iter().map(Bot::end_point).collect::<Vec<_>>();
    let (max_overlap_range, max_overlap) = find_max_overlap(&mut starts, &mut ends);

    println!("max overlap: {}", max_overlap);
    println!("max range: {:?}", max_overlap_range);
    let start_distance = max_overlap_range.0.x.abs() + max_overlap_range.0.y.abs() + max_overlap_range.0.z.abs();
    let end_distance = max_overlap_range.1.x.abs() + max_overlap_range.1.y.abs() + max_overlap_range.1.z.abs();
    println!("distances: {}, {}", start_distance, end_distance);
}
