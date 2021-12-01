import * as fs from 'fs';

let input = fs.readFileSync(process.stdin.fd, 'utf-8');
let numbers = input.split('\n')
                .map(n => +n);

let lastSum = numbers.slice(0, 3).reduce((acc, n) => acc + n, 0);
let count = 0;
for (let i = 1; i < numbers.length - 2; i++) {
    let currSum = numbers.slice(i, i+3).reduce((acc, n) => acc + n, 0);
    if (currSum > lastSum) {
        count++;
    }
    lastSum = currSum;
}

console.log(count);