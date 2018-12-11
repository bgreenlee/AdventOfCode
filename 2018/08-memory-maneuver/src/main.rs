use std::io::{self, Read};

#[derive(Debug)]
struct Node {
    children: Vec<Node>,
    metadata: Vec<usize>,
}

impl Node {
    fn new() -> Node {
        Node { children: Vec::new(), metadata: Vec::new() }
    }

    fn add_child(&mut self, node: Node) {
        self.children.push(node);
    }

    fn add_metadata(&mut self, metadata: &[usize]) {
        metadata.iter().for_each(|m| self.metadata.push(*m))
    }

    fn sum_metadata(&self) -> usize {
        let child_sum : usize = self.children.iter().map(|c| c.sum_metadata()).sum();
        let self_sum : usize = self.metadata.iter().sum();
        child_sum + self_sum
    }

    fn value(&self) -> usize {
        // if we don't have children, our value is the sum of our metadata
        // otherwise, our value is the sum of our children as indexed by our metadata
        if self.children.is_empty() {
            self.metadata.iter().sum()
        } else {
            self.metadata.iter().map(|i|
                if *i <= self.children.len() {
                    self.children[*i-1].value()
                } else {
                    0
                }
            ).sum()
        }
    }
}

fn create_node(mut input: &[usize]) -> (Node, &[usize]) {
    let mut node = Node::new();

    let (num_children, num_metadata) = (input[0], input[1]);

    for _ in 0..num_children {
        let (child, tail) = create_node(&input[2..]);
        node.add_child(child);
        input = tail;
    }

    node.add_metadata(&input[2..num_metadata+2]);
    (node, &input[num_metadata..])
}

fn main() {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer).expect("Error reading from stdin");
    let input : Vec<usize> = buffer
        .trim()
        .split_whitespace().map(|n| n.parse::<usize>().expect("could not parse number"))
        .collect();

    let (node, _) = create_node(&input);

    println!("sum: {}", node.sum_metadata());
    println!("value: {}", node.value());
}
