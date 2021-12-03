import * as fs from 'fs';

class Command {
    movement: string;
    distance: number;
    readonly parseRE = /(forward|down|up)\s+(\d+)/i;

    constructor(line: string) {
        let parse = line.match(this.parseRE);
        if (parse === null) {
            throw new Error(`Invalid command: ${line}`);
        }
        this.movement = parse[1];
        this.distance = +parse[2];
    }
}

let input = fs.readFileSync(process.stdin.fd, 'utf-8');
let lines = input.split('\n');
let commands = lines.map(l => new Command(l))

let pos = 0, depth = 0, aim = 0;
for (let command of commands) {
    switch (command.movement) {
        case "forward":
            pos += command.distance;
            depth += aim * command.distance;
            break;
        case "down":
            aim += command.distance;
            break;
        case "up":
            aim -= command.distance;
        default:
            break;
    }
}

console.log(`pos: ${pos}, depth: ${depth}, answer: ${pos * depth}`);
