use std::fmt;
use std::collections::HashSet;
use std::hash::{Hash, Hasher};
// use std::cmp::{Eq, PartialEq};

fn main() {
    let mut board = Board {
        hallway: ['.'; 11],
        rooms: [['B', 'A'], ['C', 'D'], ['B', 'C'], ['D', 'A']],
        energy: 0,
    };

    println!("{}", board);

    // // for each player, attempt all possible moves
    // // repeat until we reach our goal
    // let mut energy = 0;
    // let mut energies = Vec::new();
    // while !board.is_goal() {
    //     // println!("{}", board);
    //     for player in board.players() {
    //         for destination in board.moves(player) {
    //             // energy += board.move_player(player, destination);
    //             if board.is_goal() {
    //                 println!("Goal: {}", energy);
    //                 energies.push(energy);
    //                 energy = 0;
    //                 break;
    //             }
    //         }
    //     }
    // }
    // dbg!(energies);
}

type Point = (usize, usize);

#[derive(Clone,Copy,Debug)]
struct Board {
    hallway: [char; 11],
    rooms: [[char; 2]; 4],
    energy: u32,
}

impl Board {
    fn new(hallway: [char; 11], rooms: [[char; 2]; 4]) -> Self {
        Self { hallway, rooms, energy: 0 }
    }

    // return the location of all the players
    // fn players(&self) -> Vec<Point> {
    //     let mut players = Vec::new();
    //     for y in 0..3 {
    //         for x in 0..11 {
    //             if ('A'..='D').contains(&self.grid((x,y))) {
    //                 players.push((x,y));
    //             }
    //         }
    //     }
    //     players
    // }

//     // generate a list of valid moves for the given point
//     fn moves(&self, start: Point) -> Vec<Point> {
//         let player = self.grid(start);
//         // can't move if we're not a letter
//         if !('A'..='D').contains(&player) {
//             return vec![];
//         }
//         // if we're already where we're supposed to be, don't move
//         if player == 'A' && start == (2,2) ||
//            player == 'B' && start == (4,2) ||
//            player == 'C' && start == (6,2) ||
//            player == 'D' && start == (8,2) {
//             return vec![];
//         } 

//         let mut moves = Vec::new();
//         let mut stack = Vec::new();
//         let mut visited = HashSet::new();
//         stack.push(start);
//         visited.insert(start);
//         while let Some(next) = stack.pop() {
//             for neighbor in self.neighbors(next) {
//                 if !visited.contains(&neighbor) {
//                     stack.push(neighbor);
//                     moves.push(neighbor);
//                     visited.insert(neighbor);
//                 }
//             }
//         }
//         // filter out illegal moves
//         moves.into_iter()
//             .filter(|point|
//                 !(
//                     [(2,0), (4,0), (6,0), (8,0)].contains(point) // can't stop outside a room
//                     || (*point == (2,1) && self.grid((2,2)) != player) // can't enter a
//                     || (*point == (4,1) && self.grid((4,2)) != player) // room occupied💣
//                     || (*point == (6,1) && self.grid((6,2)) != player) // by a different
//                     || (*point == (8,1) && self.grid((8,2)) != player) // player type
//                 )
//             )
//             .collect()
//     }

//     fn neighbors(&self, point: Point) -> Vec<Point> {
//         let (x, y) = point;
//         let mut points = Vec::new();
//         if x < 10 {
//             points.push((x+1, y));
//         }
//         if y < 2 {
//             points.push((x, y+1));
//         }
//         if x > 0 {
//             points.push((x-1, y));
//         }
//         if y > 0 {
//             points.push((x, y-1));
//         }
//         points.into_iter()
//             .filter(|p| self.grid(*p) == '.')
//             .collect()
//     }

//     // move the player to the point
//     // assumes the move is a legal one
//     fn move_player(&mut self, from: Point, to: Point) {
//         let player = self.grid(from);
//         if !('A'..='D').contains(&player) {
//             return; // not a player
//         }
//         // do the move
//         self.grid[to.1][to.0] = player;
//         self.grid[from.1][from.0] = '.';
//         // calculate the energy
//         // luckily the distance is fairly easy to calculate, since we can only move along the hallway
//         // or to/from rooms
//         let distance = (to.0 as i32 - from.0 as i32).abs() as u32 + from.1 as u32 + to.1 as u32;
//         let multiplier = 10u32.pow(player as u32 - 65);
//         self.energy = distance * multiplier
//     }

    // return true if the board is in the goal state
    fn is_goal(&self) -> bool {
        self.rooms[0] == ['A','A'] &&
        self.rooms[1] == ['B','B'] &&
        self.rooms[2] == ['C','C'] &&
        self.rooms[3] == ['D','D']
    }
    
    // hacky way to get the index of the room each player is supposed to be in
    fn homeroom(player: char) -> usize {
        (player as u32 - 'A' as u32) as usize
    }

    // player can enter a room only if it is their homeroom and
    // there are no other players in the room who shouldn't be there
    fn can_enter_room(&self, player: char, room: usize) -> bool {
        room == Self::homeroom(player) && 
        self.rooms[room].iter().all(|c| *c == '.' || room == Self::homeroom(*c))
    }

    // get all valid states where a player moves out of a room into the hallway
    // fn room_to_hallway_states(&self) -> Vec<(Board, usize)> {
    //     self.rooms.iter()
    // }
}

impl fmt::Display for Board {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "#############\n")?;
        write!(f, "#{}#\n", self.hallway.iter().collect::<String>())?;
        for i in 0..2 {
            write!(f, "###")?;
            for r in 0..4 {
                write!(f, "{}#", self.rooms[r][i])?;
            }
            write!(f, "##\n")?;
        }
        write!(f, "  #########")?;
        Ok(())
    }
}

// impl Clone for Point {
//     fn clone(&self) -> Point { *self }
// }

impl Hash for Board {
    fn hash<H: Hasher>(&self, state: &mut H) {
        self.hallway.hash(state);
        self.rooms.hash(state);
    }
}

// impl PartialEq for Point {
//     fn eq(&self, other: &Point) -> bool {
//         self.x == other.x && self.y == other.y
//     }
// }

// impl Eq for Point {}

#[cfg(test)]
mod tests {
    // use super::*;

    // #[test]
    // fn test_moves() {
    //     let board = Board::new(
    //             ['.','.','.','B','.','.','.','.','.','.','.'],
    //             [['B','A'], ['C','D'], ['.','C'], ['D','A']],
    //         );
        
    //     assert_eq!(board.moves((0,0)), vec![]); // can't move an empty space
    //     assert_eq!(board.moves((2,2)), vec![]); // can't move a blocked player
    //     assert_eq!(
    //         HashSet::<Point>::from_iter(board.moves((2,1))),
    //         HashSet::<Point>::from_iter(vec![(0,0), (1,0)])
    //     );
    //     assert_eq!(
    //         HashSet::<Point>::from_iter(board.moves((4,1))),
    //         HashSet::<Point>::from_iter(vec![(5,0), (6,1), (7,0), (9,0), (10,0)])
    //     ); 
    //     assert_eq!(
    //         HashSet::<Point>::from_iter(board.moves((8,1))),
    //         HashSet::<Point>::from_iter(vec![(5,0), (7,0), (9,0), (10,0)])
    //     ); 
    // }

//     #[test]
//     fn test_move_player() {
//         let mut board = Board::new([
//             ['.','.','.','B','.','.','.','.','.','.','.'],
//             ['#','#','B','#','C','#','.','#','D','#','#'],
//             ['#','#','A','#','D','#','C','#','A','#','#'],
//         ]);

//         let energy = board.move_player((4,1), (6,1));
//         assert_eq!(board.grid((4,1)), '.');
//         assert_eq!(board.grid((6,1)), 'C');
//         assert_eq!(board.energy, 400);
//     }
}

#[allow(unused_macros)]
macro_rules! dbg {
    ($x:expr) => {
        println!("{} = {:?}", stringify!($x), $x);
    };
}
