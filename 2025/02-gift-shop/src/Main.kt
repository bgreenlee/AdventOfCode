import java.io.File

fun main() {
    val lines = File("data/input.dat").readLines()
    val input = lines.first()
            .split(',')
            .map { it.split('-') }
    println("part 1: " + part1(input))
    println("part 2: " + part2(input))
}

fun part1(input: List<List<String>>): Long {
    var invalidSum: Long = 0
    for (pair in input) {
        val startStr = pair[0]
        val endStr = pair[1]
        // if they are both the same length and of odd length, we can skip
        if (startStr.length % 2 == 1 && startStr.length == endStr.length) {
            continue
        }
        val start = startStr.toLong()
        val end = endStr.toLong()
        for (num in start..end) {
            val numStr = num.toString()
            if (numStr.length % 2 == 1) continue // skip odd-length numbers
            val firstHalf = numStr.slice(0..<numStr.length / 2)
            val secondHalf = numStr.slice(numStr.length / 2..<numStr.length)
            if (firstHalf == secondHalf) invalidSum += num
        }
    }
    return invalidSum
}

fun part2(input: List<List<String>>): Long {
    var invalidSum: Long = 0
    val invalidRegex = Regex("""^(\d+)\1+$""")
    for (pair in input) {
        val start = pair[0].toLong()
        val end = pair[1].toLong()
        for (num in start..end) {
            if (invalidRegex.matches(num.toString())) {
                invalidSum += num
            }
        }
    }
    return invalidSum
}