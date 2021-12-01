import * as fs from 'fs';

let input = fs.readFileSync(process.stdin.fd, 'utf-8');
let numbers = input.split('\n')
                .map(n => +n);

let lastNum = numbers.shift() || 0;
let count = 0;
numbers.forEach(num => {
    if (num > lastNum) {
        count++;
    }
    lastNum = num;
});

console.log(count);