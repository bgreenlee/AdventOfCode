export function log(...args: any[]) {
    if (process.env.DEBUG) {
        console.log(...args);
    }
}