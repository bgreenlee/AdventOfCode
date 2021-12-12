use std::collections::{HashMap, HashSet};
use std::io::{self, Read};

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

    fn paths(&mut self, start: &str, end: &str) -> Vec<Vec<String>> {
        let mut current_path: Vec<String> = Vec::new();
        let mut simple_paths: Vec<Vec<String>> = Vec::new();
        let mut visited: HashSet<String> = HashSet::new();

        current_path.push(start.to_string());
        Self::depth_first_search(
            self,
            start,
            end,
            &mut current_path,
            &mut simple_paths,
            &mut visited,
        );
        return simple_paths;
    }

    fn depth_first_search(
        map: &Map,
        start: &str,
        end: &str,
        current_path: &mut Vec<String>,
        simple_paths: &mut Vec<Vec<String>>,
        visited: &mut HashSet<String>,
    ) {
        let node = map.map.get(start).unwrap();
        if node.is_small() && visited.contains(start) {
            return;
        }
        visited.insert(start.to_string());
        current_path.push(start.to_string());
        if start == end {
            simple_paths.push(current_path.clone());
            visited.remove(start);
            current_path.pop();
            return;
        }
        for connection in &node.connections {
            Self::depth_first_search(map, connection, end, current_path, simple_paths, visited);
        }
        current_path.pop();
        visited.remove(start);
    }
}

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

    fn is_small(&self) -> bool {
        self.name.chars().nth(0).unwrap() >= 'a'
    }
}

fn main() {
    let mut buffer = String::new();
    io::stdin()
        .read_to_string(&mut buffer)
        .expect("Error reading from stdin");
    let lines: Vec<&str> = buffer.lines().collect();

    let mut map = Map::new(lines);
    let paths = map.paths("start", "end");
    println!("{}", paths.len());
}
