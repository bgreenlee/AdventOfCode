use std::collections::{HashMap, HashSet};
use std::io::{self, Read};

struct Node {
    name: String,
    connections: HashSet<String>,
}

impl Node {
    fn new(name: &str) -> Node {
        Node {
            name: String::from(name),
            connections: HashSet::new(),
        }
    }

    fn is_small(name: &str) -> bool {
        name.chars().count() > 0 && name.chars().nth(0).unwrap().is_lowercase()
    }
    
    fn is_start(name: &str) -> bool {
        name == "start"
    }
    
    fn is_end(name: &str) -> bool {
        name == "end"
    }
}



struct Map {
    map: HashMap<String, Node>,
}

impl Map {
    fn new(lines: Vec<&str>) -> Map {
        let mut map = HashMap::new();
        for line in lines {
            let nodes: Vec<&str> = line.split("-").collect();
            let (from, to) = (nodes[0], nodes[1]);

            let from_node = map.entry(from.to_string()).or_insert(Node::new(from));
            from_node.connections.insert(String::from(to));
            let to_node = map.entry(to.to_string()).or_insert(Node::new(to));
            to_node.connections.insert(String::from(from));
        }
        Map { map }
    }

    fn paths(&self, start: &str, end: &str, extra_visit: bool) -> Vec<Vec<String>> {
        let mut current_path: Vec<String> = Vec::new();
        let mut simple_paths: Vec<Vec<String>> = Vec::new();

        self.depth_first_search(start, end, &mut current_path, &mut simple_paths, extra_visit);

        simple_paths
    }

    fn depth_first_search(&self, from: &str, to: &str,
        current_path: &mut Vec<String>, simple_paths: &mut Vec<Vec<String>>, extra_visit: bool)
    {
        if Node::is_small(from) && current_path.contains(&from.to_string()) {
            if !extra_visit || Node::is_start(from) || Node::is_end(from) {
                return
            }
        
            // a whole lotta work to see if we've already had our extra visit
            let mut visit_counts: HashMap<String, u8> = HashMap::new();
            for i in 0..current_path.len() {
                let cave = &current_path[i];
                if Node::is_small(cave) && !Node::is_start(cave) && !Node::is_end(cave) {
                    *visit_counts.entry(cave.to_string()).or_default() += 1;
                }
            }
            if visit_counts.values().max().unwrap_or(&0) > &1 {
                return;
            }
        }

        current_path.push(from.to_string());

        if from == to {
            simple_paths.push(current_path.clone());
            current_path.pop();
            return;
        }

        let node = self.map.get(from).unwrap();
        for connection in &node.connections {
            self.depth_first_search(connection, to, current_path, simple_paths, extra_visit);
        }

        current_path.pop();
    }
}


fn main() {
    let mut buffer = String::new();
    io::stdin()
        .read_to_string(&mut buffer)
        .expect("Error reading from stdin");
    let lines: Vec<&str> = buffer.lines().collect();

    let map = Map::new(lines);
    let part1_paths = map.paths("start", "end", false);
    println!("{}", part1_paths.len());

    let part2_paths = map.paths("start", "end", true);
    println!("{}", part2_paths.len());
}
