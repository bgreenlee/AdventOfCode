use std::io::{self, Read};
use regex::Regex;
use std::cmp::{Eq, PartialEq};

fn main() {
    let mut buffer = String::new();
    io::stdin()
        .read_to_string(&mut buffer)
        .expect("Error reading from stdin");
    let lines: Vec<&str> = buffer.lines().collect();

    let re = Regex::new(r"^(on|off)\s+x=([-\d]+)..([-\d]+),y=([-\d]+)..([-\d]+),z=([-\d]+)..([-\d]+)$").unwrap();
    let mut cuboids = Vec::<Cuboid>::new();
    for line in lines {
        let m = re.captures(line).unwrap();
        let is_on = m[1].eq("on");
        // we add one to each axis because (0..0, 0..0, 0..0) would be considered a 1-cube cuboid
        let cuboid = Cuboid::new(
            m[2].parse::<i32>().unwrap() .. m[3].parse::<i32>().unwrap() + 1,
            m[4].parse::<i32>().unwrap() .. m[5].parse::<i32>().unwrap() + 1,
            m[6].parse::<i32>().unwrap() .. m[7].parse::<i32>().unwrap() + 1
        );
        // for each previous "on" cuboid, we subtract the current cuboid
        // this gives us zero to six new "on" cuboids
        // then if this is an on cuboid, we add it to the list
        cuboids = cuboids.iter()
            .flat_map(|c| c.subtract(&cuboid))
            .collect::<Vec<Cuboid>>();
        if is_on {
            cuboids.push(cuboid);
        }
    }
    println!("{}", cuboids.iter().map(|c| c.volume()).sum::<u64>());
}

// implementing our own Range because Rust's doesn't implement Copy
#[derive(Clone,Copy,Debug)]
struct Range {
    start: i32,
    end: i32,
}

impl Range {
    fn new(range: std::ops::Range<i32>) -> Range {
        Range { start: range.start, end: range.end }
    }

    fn len(&self) -> u32 {
        (self.end - self.start).abs() as u32
    }

    fn overlaps(&self, other: &Range) -> bool {
        (self.start..=self.end).contains(&other.start) || (self.start..=self.end).contains(&other.end) ||
        (other.start..=other.end).contains(&self.start) || (other.start..=other.end).contains(&self.end)
    }

    fn contains(&self, other: &Range) -> bool {
        (self.start..=self.end).contains(&other.start) && (self.start..=self.end).contains(&other.end)
    }

    fn intersection(&self, other: &Range) -> Option<Range> {
        if !self.overlaps(other) {
            return None
        }
        if self.contains(other) {
            return Some(*other);
        }
        if other.contains(self) {
            return Some(*self);
        }
        Some(Range::new(self.start.max(other.start)..self.end.min(other.end)))
    }
}

impl PartialEq for Range {
    fn eq(&self, other: &Range) -> bool {
        self.start == other.start && self.end == other.end
    }
}

impl Eq for Range {}

#[derive(Clone,Copy,Debug)]
struct Cuboid {
    xrange: Range,
    yrange: Range,
    zrange: Range,
}

impl Cuboid {
    fn new(xrange: std::ops::Range<i32>, yrange: std::ops::Range<i32>, zrange: std::ops::Range<i32>) -> Cuboid {
        Cuboid {
            xrange: Range::new(xrange),
            yrange: Range::new(yrange),
            zrange: Range::new(zrange),
        }
    }

    fn volume(&self) -> u64 {
        self.xrange.len() as u64 *
        self.yrange.len() as u64 *
        self.zrange.len() as u64
    }

    // return the cuboid region of the intersection of these cuboids, if any
    fn intersection(&self, other: &Cuboid) -> Option<Cuboid> {
        // do the easy ones first
        if !self.overlaps(other) {
            return None;
        }
        // if the other is fully contained by self, return self
        if self.contains(other) {
            return Some(*other);
        }
        // if self is fully contained by other, return other
        if other.contains(self) {
            return Some(*self);
        }

        // we know these must intersect, so we unwrap with abandon
        let xrange = self.xrange.intersection(&other.xrange).unwrap();
        let yrange = self.yrange.intersection(&other.yrange).unwrap();
        let zrange = self.zrange.intersection(&other.zrange).unwrap();

        Some(Cuboid { xrange, yrange, zrange })
    }

    fn overlaps(&self, other: &Cuboid) -> bool {
        self.xrange.overlaps(&other.xrange) &&
        self.yrange.overlaps(&other.yrange) &&
        self.zrange.overlaps(&other.zrange)
    }

    fn contains(&self, other: &Cuboid) -> bool {
        self.xrange.contains(&other.xrange) &&
        self.yrange.contains(&other.yrange) &&
        self.zrange.contains(&other.zrange)
    }

    // subtract the other cuboid from this one, returning one or more sub-cuboids
    fn subtract(&self, other: &Cuboid) -> Vec<Cuboid> {
        if !self.overlaps(other) {
            return vec![*self];
        }
        // we know this must intersect because it overlaps
        let intersection = self.intersection(other).unwrap();
        // generate our sub-cuboids
        let new_cuboids = vec![
            Cuboid {
                xrange: Range::new(self.xrange.start..intersection.xrange.start),
                yrange: self.yrange,
                zrange: self.zrange
            },
            Cuboid {
                xrange: Range::new(intersection.xrange.end..self.xrange.end),
                yrange: self.yrange,
                zrange: self.zrange
            },
            Cuboid {
                xrange: intersection.xrange,
                yrange: Range::new(self.yrange.start..intersection.yrange.start),
                zrange: self.zrange
            },
            Cuboid {
                xrange: intersection.xrange,
                yrange: Range::new(intersection.yrange.end..self.yrange.end),
                zrange: self.zrange
            },
            Cuboid {
                xrange: intersection.xrange,
                yrange: intersection.yrange,
                zrange: Range::new(self.zrange.start..intersection.zrange.start)
            },
            Cuboid {
                xrange: intersection.xrange,
                yrange: intersection.yrange,
                zrange: Range::new(intersection.zrange.end..self.zrange.end)
            }
        ];
        // remove any empty ones   
        new_cuboids.into_iter()
            .filter(|c| c.volume() > 0)
            .collect()
    }
}

impl PartialEq for Cuboid {
    fn eq(&self, other: &Cuboid) -> bool {
        self.xrange == other.xrange && 
        self.yrange == other.yrange &&
        self.zrange == other.zrange
    }
}

impl Eq for Cuboid {}

#[allow(unused_macros)]
macro_rules! dbg {
    ($x:expr) => {
        println!("{} = {:?}", stringify!($x), $x);
    };
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_range_overlaps() {
        let a = Range::new(0..10);
        let b = Range::new(-5..5);
        let c = Range::new(-100..100);
        let d = Range::new(0..1);
        let e = Range::new(20..30);

        assert_eq!(a.overlaps(&b), true);
        assert_eq!(a.overlaps(&c), true);
        assert_eq!(a.overlaps(&d), true);
        assert_eq!(a.overlaps(&e), false);
    }

    #[test]
    fn test_range_contains() {
        let a = Range::new(0..10);
        let b = Range::new(2..3);
        let c = Range::new(0..5);
        let d = Range::new(5..15);
        let e = Range::new(20..30);

        assert_eq!(a.contains(&b), true);
        assert_eq!(a.contains(&c), true);
        assert_eq!(a.contains(&d), false);
        assert_eq!(a.contains(&e), false);
    }

    #[test]
    fn test_range_intersection() {
        let a = Range::new(0..10);
        let b = Range::new(2..3);
        let c = Range::new(-5..15);
        let d = Range::new(5..15);
        let e = Range::new(20..30);

        assert_eq!(a.intersection(&b), Some(b));
        assert_eq!(a.intersection(&c), Some(a));
        assert_eq!(a.intersection(&d), Some(Range::new(5..10)));
        assert_eq!(a.intersection(&e), None);
    }

    #[test]
    fn test_cuboid_overlaps() {
        let a = Cuboid::new(0..10, 0..10, 0..10);
        let b = Cuboid::new(0..5, 0..5, 0..5);
        let c = Cuboid::new(0..10, 20..30, 20..30);
        let d = Cuboid::new(20..30, 20..30, 20..30);
        assert_eq!(a.overlaps(&b), true);
        assert_eq!(b.overlaps(&a), true);
        assert_eq!(a.overlaps(&c), false);
        assert_eq!(a.overlaps(&d), false);
    }

    #[test]
    fn test_cuboid_contains() {
        let a = Cuboid::new(0..10, 0..10, 0..10);
        let b = Cuboid::new(0..5, 0..5, 0..5);
        let c = Cuboid::new(0..10, 20..30, 20..30);
        assert_eq!(a.contains(&b), true);
        assert_eq!(b.contains(&a), false);
        assert_eq!(a.contains(&c), false);
    }

    #[test]
    fn test_cuboid_intersection() {
        let a = Cuboid::new(0..10, 0..10, 0..10);
        let b = Cuboid::new(0..5, 0..5, 0..5);
        let c = Cuboid::new(0..10, 20..30, 20..30);
        let d = Cuboid::new(5..15, 5..15, 5..15);
        assert_eq!(a.intersection(&b), Some(b));
        assert_eq!(b.intersection(&a), Some(b));
        assert_eq!(a.intersection(&c), None);
        assert_eq!(a.intersection(&d), Some(Cuboid::new(5..10, 5..10, 5..10)));
    }

    #[test]
    fn test_cuboid_subtract() {
        let a = Cuboid::new(0..10, 0..10, 0..10);
        let b = Cuboid::new(9..10, 9..10, 9..10);
        let c = Cuboid::new(5..6, 5..6, 5..6);
        let d = Cuboid::new(20..30, 20..30, 20..30);
        let e = Cuboid::new(-5..15, -5..15, -5..15);

        assert_eq!(a.subtract(&b), vec![
            Cuboid::new(0..9, 0..10, 0..10),
            Cuboid::new(9..10, 0..9, 0..10),
            Cuboid::new(9..10, 9..10, 0..9),
        ]);
        assert_eq!(a.subtract(&c), vec![
            Cuboid::new(0..5, 0..10, 0..10),
            Cuboid::new(6..10, 0..10, 0..10),
            Cuboid::new(5..6, 0..5, 0..10),
            Cuboid::new(5..6, 6..10, 0..10),
            Cuboid::new(5..6, 5..6, 0..5),
            Cuboid::new(5..6, 5..6, 6..10),
        ]);
        assert_eq!(a.subtract(&d), vec![a]);
        assert_eq!(a.subtract(&e), vec![]);
    }
}