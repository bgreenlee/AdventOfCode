//TIP To <b>Run</b> code, press <shortcut actionId="Run"/> or
// click the <icon src="AllIcons.Actions.Execute"/> icon in the gutter.
import java.io.File

fun main() {
    val input = File("data/input.dat").readLines()
    println("part 1: " + part1(input))
    println("part 2: " + part2(input))
}

fun part1(input: List<String>): Int {
    var sum = 50
    var zeroCount = 0
    for (rotStr in input) {
        val dir = if (rotStr[0] == 'R') 1 else -1
        val num = rotStr.drop(1).toInt()
        sum += num * dir
        // normalize
        sum %= 100
        if (sum < 0) sum += 100
        zeroCount += if (sum == 0) 1 else 0
    }
    return zeroCount
}

fun part2(input: List<String>): Int {
    var sum = 50
    var lastSum = sum
    var zeroCount = 0
    for (rotStr in input) {
        val dir = if (rotStr[0] == 'R') 1 else -1
        val num = rotStr.drop(1).toInt()
        sum += num % 100 * dir
        // if we are <= 0 or >= 100, we've hit/passed zero—except if we started at 0
        if (sum !in 1..<100 && lastSum != 0) zeroCount += 1
        zeroCount += num / 100 // add in all the rotations
        // normalize
        sum %= 100
        if (sum < 0) sum += 100
        lastSum = sum
    }
    return zeroCount
}