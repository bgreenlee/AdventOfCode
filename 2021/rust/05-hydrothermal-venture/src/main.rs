use std::io::{self, Read};
use std::collections::HashMap;
use std::hash::{Hash, Hasher};
use std::cmp::{Eq, PartialEq};
use std::fmt;

#[derive(Debug,Copy)]
struct Point {
    x: i32,
    y: i32,
}

impl Point {
    fn new(pointstr: &str) -> Point {
        let parts : Vec<i32> = pointstr.split(",")
            .map(|c:&str| c.trim().parse::<i32>().unwrap_or(0))
            .collect();

        Point {
            x: parts[0],
            y: parts[1],
        }
    }

    fn distance_to(&self, other: &Point) -> i32 {
        (self.x - other.x).abs() + (self.y - other.y).abs()
    }

    fn add(&self, x: i32, y: i32) -> Point {
        Point {
            x: self.x + x,
            y: self.y + y,
        }
    }
}

impl Clone for Point {
    fn clone(&self) -> Point { *self }
}

impl Hash for Point {
    fn hash<H: Hasher>(&self, state: &mut H) {
        self.x.hash(state);
        self.y.hash(state);
    }
}

impl PartialEq for Point {
    fn eq(&self, other: &Point) -> bool {
        self.x == other.x && self.y == other.y
    }
}

impl Eq for Point {}

impl fmt::Display for Point {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "({},{})", self.x, self.y)
    }
}

#[derive(Debug)]
struct Line {
    start: Point,
    end: Point,
}

impl Line {
    fn new(linestr: &str) -> Line {
        let points: Vec<Point> = linestr.split("->").map(Point::new).collect();

        Line {
            start: points[0],
            end: points[1],
        }
    }

    // return all the points on a line
    fn points(&self) -> Vec<Point> {
        let distance = self.start.distance_to(&self.end);
        let xstep = (self.end.x - self.start.x) as f32 / distance as f32;
        let ystep = (self.end.y - self.start.y) as f32 / distance as f32;
        let mut points: Vec<Point> = Vec::new();
        let mut curpoint = self.start;
        while curpoint != self.end {
            points.push(curpoint);
            curpoint = curpoint.add(xstep.round() as i32, ystep.round() as i32);
        }
        points.push(self.end);
        points
    }

    fn is_straight(&self) -> bool {
        self.start.x == self.end.x || self.start.y == self.end.y
    }
}

impl fmt::Display for Line {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{} -> {}", self.start, self.end)
    }
}

fn main() {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer).expect("Error reading from stdin");
    let lines: Vec<Line> = buffer.lines().map(Line::new).collect();

    let straight_lines = lines.iter().filter(|l| l.is_straight());
    let mut map: HashMap<Point, i32> = HashMap::new();
    for line in straight_lines {
        for point in line.points() {
            *map.entry(point).or_insert(0) += 1;
        }
    }
    let overlaps = map.values().filter(|n| **n > 1).count();
    println!("Part 1: {}", overlaps);

    map = HashMap::new();
    for line in lines {
        for point in line.points() {
            *map.entry(point).or_insert(0) += 1;
        }
    }
    let overlaps = map.values().filter(|n| **n > 1).count();
    println!("Part 2: {}", overlaps);
}

