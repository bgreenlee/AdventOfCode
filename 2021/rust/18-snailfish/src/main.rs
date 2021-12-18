use std::ops;
use std::cmp::{Eq, PartialEq};
// use std::io::{self, Read};

#[derive(Clone, Debug)]
enum Element {
    Number(Box<Number>),
    Int(u32),
}

#[derive(Clone, Debug)]
struct Number {
    left: Element,
    right: Element,
}

impl ops::Add<Number> for Number {
    type Output = Number;

    fn add(self, rhs: Number) -> Number {
        Number {
            left: Element::Number(Box::new(Number{ left: self.left, right: self.right})),
            right: Element::Number(Box::new(Number{ left: rhs.left, right: rhs.right})),
        }
    }
}

impl PartialEq for Number {
    fn eq(&self, other: &Number) -> bool {
        match (self, other) {
            ( Number{left: Element::Int(al), right: Element::Int(ar)},
              Number{left: Element::Int(bl), right: Element::Int(br)} ) => al == bl && ar == br,
            ( Number{left: Element::Int(al), right: Element::Number(ar)},
              Number{left: Element::Int(bl), right: Element::Number(br)} ) => al == bl && ar == br,
            ( Number{left: Element::Number(al), right: Element::Int(ar)},
              Number{left: Element::Number(bl), right: Element::Int(br)} ) => al == bl && ar == br,
            ( Number{left: Element::Number(al), right: Element::Number(ar)},
              Number{left: Element::Number(bl), right: Element::Number(br)} ) => al == bl && ar == br,
            _ => false
        }
    }
}

impl Eq for Number {}

impl Number {
    fn reduce(&mut self) {
        // if any pair is nested inside four pairs, the leftmost such pair explodes
        // if self.depth() >= 4 {
        //     let mut leftmost = self.leftmost();
        // }
    }

    // depth is how many levels of nesting this number has
    // [1,2] has a depth of 0
    // [[1,2],3] has a depth of 1, etc.
    fn depth(&self) -> u32 {
        return match self {
            Number{left: Element::Int(_), right: Element::Int(_)} => return 0,
            Number{left: Element::Number(a), right: Element::Int(_)} => a.depth() + 1,
            Number{left: Element::Int(_), right: Element::Number(b)} => return b.depth() + 1,
            Number{left: Element::Number(a), right: Element::Number(b)} => return u32::max(a.depth(), b.depth()) + 1,
        }
    }

    fn leftmost(&self) -> &Number {
        return match self {
            Number{left: Element::Int(_), right: Element::Int(_)} => self,
            Number{left: Element::Number(a), right: Element::Int(_)} => a.leftmost(),
            Number{left: Element::Int(_), right: Element::Number(b)} => b.leftmost(),
            Number{left: Element::Number(a), right: Element::Number(b)} => 
                if b.depth() > a.depth() { b.leftmost() } else { a.leftmost() }
        }        
    }

    fn rightmost(&self) -> &Number {
        return match self {
            Number{left: Element::Int(_), right: Element::Int(_)} => self,
            Number{left: Element::Number(a), right: Element::Int(_)} => a.rightmost(),
            Number{left: Element::Int(_), right: Element::Number(b)} => b.rightmost(),
            Number{left: Element::Number(a), right: Element::Number(b)} => 
                if a.depth() < b.depth() { a.rightmost() } else { b.rightmost() }
        }        
    }
}

fn main() {
    // let mut buffer = String::new();
    // io::stdin()
    //     .read_to_string(&mut buffer)
    //     .expect("Error reading from stdin");
    // let lines: Vec<&str> = buffer.lines().collect();
    let number = parse("[9,[8,7]]");
    dbg!(number);
    let n1 = parse("[1,2]");
    let n2 = parse("[[3,4],5]");
    dbg!(n1 + n2);
}

fn parse(line: &str) -> Number {
    let mut stack: Vec<Element> = Vec::new();
    for char in line.chars() {
        match char {
            ']' => {
                let right = stack.pop().unwrap();
                let left = stack.pop().unwrap();
                stack.push(Element::Number(Box::new(Number{left, right})));
            },
            num if num.is_ascii_digit() => stack.push(Element::Int(num.to_digit(10).unwrap())),
            _ => {},
        }
    }

    // should have just one Element::Number on the stack
    match stack[0].clone() {
        Element::Number(number) => *number,
        _ => panic!(),
    }
}

#[allow(unused_macros)]
macro_rules! dbg {
    ($x:expr) => {
        println!("{} = {:?}",stringify!($x),$x);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse() {
        let number = parse("[[1,2],3]");

        match number.left {
            Element::Number(num) => {
                match num.left {
                    Element::Int(n) => assert_eq!(n, 1),
                    _ => panic!(),
                };
                match num.right {
                    Element::Int(n) => assert_eq!(n, 2),
                    _ => panic!(),
                };
            },
            _ => panic!(),
        };

        match number.right {
            Element::Int(n) => assert_eq!(n, 3),
            _ => panic!(),
        };
    }

    #[test]
    fn test_equality() {
        assert_eq!(parse("[[1,2],3]"), parse("[[1,2],3]"));
        assert_ne!(parse("[1,2]"), parse("[[1,2],3]"));
    }

    #[test]
    fn test_depth() {
        assert_eq!(parse("[1,2]").depth(), 0);
        assert_eq!(parse("[[1,2],3]").depth(), 1);
        assert_eq!(parse("[[1,2],[[3,4],5]]").depth(), 2);
        assert_eq!(parse("[[[[[9,8],1],2],3],4]").depth(), 4);
    }

    #[test]
    fn test_leftmost() {
        assert_eq!(*parse("[1,2]").leftmost(), parse("[1,2]"));
        assert_eq!(*parse("[[[[[9,8],1],2],3],4]").leftmost(), parse("[9,8]"));
        assert_eq!(*parse("[7,[6,[5,[4,[3,2]]]]]").leftmost(), parse("[3,2]"));
    }
}