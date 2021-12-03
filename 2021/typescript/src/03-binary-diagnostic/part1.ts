import * as fs from 'fs';

let input = fs.readFileSync(process.stdin.fd, 'utf-8');
let lines = input.split('\n');

let counts = new Array<number>(lines[0].length).fill(0);
for (let line of lines) {
    let digits = line.split('');
    for (let i = 0; i < digits.length; i++) {
        counts[i] += +digits[i];
    }
}

let halfLines = lines.length / 2;
// most common bits are the counts that are half or more of the total number of lines
let gamma = counts.reduce((acc, cur, i) => {
    if (cur >= halfLines) {
        acc += Math.pow(2, counts.length - i - 1); // binary -> dec
    }
    return acc;
}, 0);
// inverse is 0x1111..1 - gamma
let eplison = Math.pow(2, counts.length) - 1 - gamma;

console.log(`Part 1: ${gamma * eplison}`);


