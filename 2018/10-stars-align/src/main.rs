#[macro_use] extern crate lazy_static;
extern crate regex;

use std::io::{self, Read};
use regex::Regex;

#[derive(Debug)]
struct Point {
    x : i32, y : i32,
    vx: i32, vy: i32,
}

impl Point {
    // Generate a point from an input string formatted like
    // position=<-39892,  -9859> velocity=< 4,  1>
    fn from_string(input: &str) -> Point {
        lazy_static! {
            static ref RE : Regex = Regex::new(r"position=<\s*(-?\d+),\s*(-?\d+)>\s+velocity=<\s*(-?\d+),\s*(-?\d+)>").unwrap();
        }
        let caps : Vec<i32> = RE.captures(input).unwrap().iter()
            .skip(1)
            .map(|c| c.unwrap().as_str().parse::<i32>().expect("parse error"))
            .collect();

        Point { x: caps[0], y: caps[1], vx: caps[2], vy: caps[3] }
    }
}

#[derive(Debug)]
struct Image {
    points: Vec<Point>,
    time: u32,
}

impl Image {
    fn new(points: Vec<Point>) -> Image {
        Image { points: points, time: 0}
    }

    fn advance(&mut self) {
        for point in self.points.iter_mut() {
            point.x += point.vx;
            point.y += point.vy;
        }
        self.time += 1;
    }

    fn rewind(&mut self) {
        for point in self.points.iter_mut() {
            point.x -= point.vx;
            point.y -= point.vy;
        }
        self.time -= 1;
    }

    // reset the image to have an origin of (0,0)
    fn normalize(&mut self) {
        let min_x = self.min_x();
        let min_y = self.min_y();
        for point in self.points.iter_mut() {
            point.x -= min_x;
            point.y -= min_y;
        }
    }

    // render the image to a string
    fn render(&self) -> String {
        let mut image : Vec<Vec<char>> = Vec::new();
        let width = self.width();
        let height = self.height();

        for _ in 0..height {
            image.push(vec!['.'; width]);
        }

        for point in &self.points {
            image[point.y as usize][point.x as usize] = '#';
        }

        image.iter()
            .map(|line| line.into_iter().collect::<String>() + "\n")
            .collect()
    }

    fn min_x(&self) -> i32 { self.points.iter().map(|p| p.x).min().unwrap() }
    fn max_x(&self) -> i32 { self.points.iter().map(|p| p.x).max().unwrap() }
    fn min_y(&self) -> i32 { self.points.iter().map(|p| p.y).min().unwrap() }
    fn max_y(&self) -> i32 { self.points.iter().map(|p| p.y).max().unwrap() }
    fn width(&self) -> usize { (self.max_x() - self.min_x()) as usize + 1 }
    fn height(&self) -> usize { (self.max_y() - self.min_y()) as usize + 1 }
    fn area(&self) -> usize { self.width() * self.height() }
}

fn main() {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer).expect("Error reading from stdin");
    let points : Vec<Point> = buffer.lines().map(|l| Point::from_string(l)).collect();
    let mut image = Image::new(points);
    let mut last_area = usize::max_value();

    // advance the positions of the points in the image until they take up minimal area
    // this is the point at which they come together to form letters
    loop {
        let area = image.area();
        if area > last_area {
            image.rewind();
            break;
        }
        last_area = area;
        image.advance();
    }
    image.normalize();
    println!("{}", image.render());
    println!("time: {}", image.time);
}
