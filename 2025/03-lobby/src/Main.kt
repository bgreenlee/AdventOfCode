import java.io.File
import java.lang.Math.powExact

fun main() {
    val input = File("data/input.dat").readLines()
    println("part 1: " + part1(input))
    println("part 2: " + part2(input))
}

fun calculateJoltage(bank: String, size: Int = 2): Long {
    val topJoltages = Array<Long>(size) { 0 }
    val batteries = bank.toCharArray().map { it.code - '0'.code }
    val batCount = batteries.count()
    for ((i, battery) in batteries.withIndex()) {
        for (j in 0..<size) {
            if (battery > topJoltages[j] && batCount - i >= size - j) {
                topJoltages[j] = battery.toLong()
                // clear remaining
                for (k in j+1..<size) {
                    topJoltages[k] = 0
                }
                break
            }
        }
    }
    val total: Long = (0..<size).fold(0) { sum, i ->
        sum + topJoltages[i] * powExact(10L, size - i - 1)
    }
    return total
}

fun part1(input: List<String>): Long {
    return input.sumOf { calculateJoltage(it) }
}

fun part2(input: List<String>): Long {
    return input.sumOf { calculateJoltage(it, 12) }
}
