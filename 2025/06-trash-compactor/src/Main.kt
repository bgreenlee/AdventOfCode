import java.io.File
import kotlin.math.max

fun main() {
    val input = File("data/input.dat").readLines()

    println("part 1: " + part1(input))
    println("part 2: " + part2(input))
}

fun <T> List<List<T>>.transpose(): List<List<T>> {
    if (isEmpty() || this[0].isEmpty()) return emptyList()
    return this[0].indices.map { i -> this.map { it[i] } }
}

fun part1(input: List<String>): Long {
    val whitespace = Regex("""\s+""")
    val numbers = input.dropLast(1)
        .map { it.trim().split(whitespace).map(String::toLong) }
        .transpose()
    val ops = input.last().trim().split(whitespace).map { it[0] }

    return numbers.zip(ops).sumOf { (col, op) ->
        col.reduce { acc, n -> if (op == '+') acc + n else acc * n }
    }
}

fun part2(input: List<String>): Long {
    // pad input to the same length
    val maxLen = input.maxOf { it.length }
    val worksheet = input
        .map { it.padEnd(maxLen).toList() }
        .transpose()

    var sum = 0L // overall sum
    var total = 0L // column total
    var op = '+'
    for (col in worksheet) {
        when (col.last()) {
            '+' -> { op = '+'; total = 0 }
            '*' -> { op = '*'; total = 1 }
        }
        val numStr = col.dropLast(1).joinToString("").trim()
        if (numStr.isEmpty()) {
            sum += total
            continue
        }
        val num = numStr.toLong()
        if (op == '+') total += num else total *= num
    }
    sum += total
    return sum
}
