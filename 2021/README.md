# Advent of Code 2021

## Typescript

### Setup

I'm setting this up so there's one top-level package.json, and then each day will be a different folder under src. This makes sure there is only one node_modules directory.

First install node if you haven't already.

Then:

```
npm init -y
npm install typescript @types/node ts-node --save-dev
npx tsc --init --rootDir src --outDir lib --esModuleInterop --resolveJsonModule --lib es6,dom  --module commonjs
echo "node_modules" >> .gitignore
```
Update the "scripts" section of your `package.json` to look like:

```
  "scripts": {
    "start":  "ts-node"
  },
```

Run like so:

`cat src/01-sonar-sweep/input.dat | npm start src/01-sonar-sweep/part2.ts1`

### Quickstart Development

Here's a program that will read from stdin and output an array of lines:

```
import * as fs from 'fs';

let input = fs.readFileSync(process.stdin.fd, 'utf-8');
let lines = input.split('\n');

console.log(lines);
```

