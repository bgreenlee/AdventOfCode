import java.io.File
import kotlin.math.max

fun main() {
    val input = File("data/input.dat").readText()
    val (freshList, ingredientsList) = input.split("\n\n")
    val freshIngredients: List<LongRange> = freshList
        .split("\n")
        .map {
            val (start, end) = it.split("-").map { it.toLong() }
            start..end
        }
    val availableIngredients = ingredientsList.split("\n").map { it.toLong() }
    println("part 1: " + part1(freshIngredients, availableIngredients))
    println("part 2: " + part2(freshIngredients))
}

fun part1(freshIngredients: List<LongRange>, availableIngredients: List<Long>): Int {
    return availableIngredients.count { ingredient ->
        freshIngredients.any { ingredient in it }
    }
}

// recursively merge [sorted] ranges
fun mergeRanges(ranges: List<LongRange>): List<LongRange> {
    if (ranges.count() < 2) return ranges
    val (a, b) = ranges
    if (a.last >= b.first - 1) {
        val newRange = a.first..max(b.last, a.last)
        return mergeRanges(listOf(newRange) + ranges.drop(2))
    }
    return listOf(a) + mergeRanges(ranges.drop(1))
}

fun part2(freshIngredients: List<LongRange>): Long {
    val sortedRanges = freshIngredients.sortedBy { it.first }
    val mergedRanges = mergeRanges(sortedRanges)
    return mergedRanges.sumOf { it.last - it.first + 1 }
}