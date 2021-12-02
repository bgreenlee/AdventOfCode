import * as fs from 'fs';

let input = fs.readFileSync(process.stdin.fd, 'utf-8');
let lines = input.split('\n');

let pos = 0, depth = 0, aim = 0;
let parseRE = /(forward|down|up)\s+(\d+)/i;

for (let line of lines) {
    let parse = line.match(parseRE);
    if (parse !== null) {
        let command = parse[1];
        let distance = +parse[2];
        switch (command) {
            case "forward":
                pos += distance;
                depth += aim * distance;
                break;
            case "down":
                aim += distance;
                break;
            case "up":
                aim -= distance;
            default:
                break;
        }
    } 
};

console.log(`pos: ${pos}, depth: ${depth}, answer: ${pos * depth}`);
