# Advent of Code 2021

## Typescript

### Setup

Install node

```
npm init -y
npm install typescript @types/node ts-node --save-dev
npx tsc --init --rootDir src --outDir lib --esModuleInterop --resolveJsonModule --lib es6,dom  --module commonjs
echo "node_modules" >> .gitignore
```

Run with `ts-node`. E.g.:

`cat src/01-sonar-sweep/input.dat | ts-node src/01-sonar-sweep/part2.ts1`
