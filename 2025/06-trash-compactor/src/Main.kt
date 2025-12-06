import java.io.File
import kotlin.math.max

fun main() {
    val input = File("data/input.dat").readLines()

    println("part 1: " + part1(input))
    println("part 2: " + part2(input))
}

// transpose a matrix
fun Array<LongArray>.transpose(): Array<LongArray> {
    val rows = this.size
    val cols = if (rows > 0) this[0].size else 0
    val result = Array(cols) { LongArray(rows) }

    for (i in 0 until rows)
        for (j in 0 until cols)
            result[j][i] = this[i][j]

    return result
}

fun part1(input: List<String>): Long {
    val whitespace = Regex("""\s+""")
    val numbers: Array<LongArray> = input.dropLast(1)
        .map { it.trim()
            .split(whitespace)
            .map { it.toLong() }
            .toLongArray()
        }
        .toTypedArray()
        .transpose()
    val ops: CharArray = input.last().trim()
        .split(whitespace)
        .map { it[0].toChar() }
        .toCharArray()

    return ops.withIndex().sumOf { (i, op) ->
        numbers[i].reduce { acc, el -> if (op == '+') acc + el else acc * el }
    }
}

// sadly it seems there is no way to make this work generically for primitive types
fun Array<CharArray>.transpose(): Array<CharArray> {
    val rows = this.size
    val cols = if (rows > 0) this[0].size else 0
    val result = Array(cols) { CharArray(rows) }

    for (i in 0 until rows)
        for (j in 0 until cols)
            result[j][i] = this[i][j]

    return result
}

fun part2(input: List<String>): Long {
    // pad input to the same length
    val maxLen = input.maxOf { it.count() }
    val paddedInput = input.map { it.padEnd(maxLen) }
    val worksheet = paddedInput.map { it.toCharArray() }
        .toTypedArray()
        .transpose()

    var sum = 0L
    var total = 0L
    var op = '+'
    for (col in worksheet) {
        when (col.last()) {
            '+' -> {
                op = '+'
                total = 0
            }
            '*' -> {
                op = '*'
                total = 1
            }
        }
        val numStr = col.dropLast(1).joinToString("").trim()
        if (numStr == "") {
            sum += total
            continue
        }
        val num = numStr.toLong()
        if (op == '+') total += num else total *= num
    }
    sum += total
    return sum
}
