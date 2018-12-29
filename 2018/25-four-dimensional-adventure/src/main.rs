use std::io::{self, Read};

type Point = (i32,i32,i32,i32);

fn distance(a: &Point, b: &Point) -> i32 {
    (a.0 - b.0).abs() + (a.1 - b.1).abs() +
    (a.2 - b.2).abs() + (a.3 - b.3).abs()
}

#[derive(Debug,Clone)]
struct Constellation {
    points: Vec<Point>,
}

impl Constellation {
    // Return true if the given point can be included in this constellation
    fn can_include(&self, point: &Point) -> bool {
        for p in &self.points {
            if distance(p, point) <= 3 {
                return true
            }
        }
        false
    }

    // Return true if the given constellation can be merged with this one. This is true if any
    // point in the given constellation could be included in this constellation.
    fn can_merge(&self, constellation: &Constellation) -> bool {
        constellation.points.iter()
            .find(|p| self.can_include(*p))
            .is_some()
    }

    // Add the given point to the constellation
    fn add(&mut self, point: Point) {
        self.points.push(point);
    }

    // Merge the given constellation into this one
    fn merge(&mut self, constellation: &Constellation) {
        constellation.points.iter().for_each(|p| self.add(*p));
    }
}

fn main() {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer).expect("Error reading from stdin");

    let mut points : Vec<Point> = Vec::new();
    for line in buffer.lines() {
        let parts = line.split(',').map(|p| p.trim().parse::<i32>().unwrap()).collect::<Vec<_>>();
        points.push((parts[0],parts[1],parts[2],parts[3]));
    }

    let mut constellations : Vec<Constellation> = Vec::new();
    'outer: while let Some(point) = points.pop() {
        // sort points by decreasing distance, so the next point popped should be the closest to
        // this one, and we're more likely to find a place for it
        for constellation in &mut constellations {
            if constellation.can_include(&point) {
                constellation.add(point);
                continue 'outer;
            }
        }
        // Couldn't find a constellation for this point, so start a new one
        constellations.push(Constellation { points: vec![point] });
    }

    // merge constellations
    let num_constellations = constellations.len();
    for _ in 0..num_constellations {
        let mut new_constellations = Vec::new();
        while let Some(mut constellation) = constellations.pop() {
            while let Some(other_constellation) = constellations.pop() {
                if constellation.can_merge(&other_constellation) {
                    constellation.merge(&other_constellation);
                } else {
                    new_constellations.push(other_constellation);
                }
            }
            new_constellations.push(constellation);
        }
        new_constellations.reverse(); // so we're not processing the same one to start
        constellations = new_constellations;
    }

    println!("num constellations: {}", constellations.len());
}
