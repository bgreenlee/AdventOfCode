import java.io.File
import kotlin.math.abs

fun main() {
    val input = File("data/input.dat").readLines()
    val points = input.map {
        val (x, y) = it.split(",").map(String::toInt)
        Point(x, y)
    }

    println("part 1: " + part1(points))
    println("part 2: " + part2(points))
}

data class Point(val x: Int, val y: Int) {
    override fun toString() = "$x,$y"
}

data class Edge(val p1: Point, val p2: Point) {
    val minX = minOf(p1.x, p2.x)
    val maxX = maxOf(p1.x, p2.x)
    val minY = minOf(p1.y, p2.y)
    val maxY = maxOf(p1.y, p2.y)

    fun contains(p: Point): Boolean =
        p.x in minX..maxX && p.y in minY..maxY

    override fun toString() = "${p1.x},${p1.y} -> ${p2.x},${p2.y}"
}

data class Rectangle(val p1: Point, val p2: Point) {
    val minX = minOf(p1.x, p2.x)
    val maxX = maxOf(p1.x, p2.x)
    val minY = minOf(p1.y, p2.y)
    val maxY = maxOf(p1.y, p2.y)
    val xInterior = (minX+1)..<maxX
    val yInterior = (minY+1)..<maxY
    val area = (abs(p1.x - p2.x) + 1L) * (abs(p1.y - p2.y) + 1L)

    override fun toString() = "$p1 -> $p2"

    fun contains(p: Point): Boolean = p.x in xInterior && p.y in yInterior

    fun contains(edge: Edge): Boolean =
        // check if either end is in rect
        contains(edge.p1) || contains(edge.p2) ||
        // check if line crosses rect horizontally
        (edge.minX <= minX && edge.maxX >= maxX &&  edge.p1.y in yInterior) ||
        // or vertically
        (edge.minY <= minY && edge.maxY >= maxY && edge.p1.x in xInterior)
}

fun part1(points: List<Point>): Long {
    var maxArea = 0L
    for (i in 0 until points.size - 1)
        for (j in i+1 until points.size)
            maxArea = maxOf(maxArea, Rectangle(points[i], points[j]).area)

    return maxArea
}

fun part2(points: List<Point>): Long {
    // build list of edges
    val edges = mutableListOf<Edge>()
    for ((i, p) in points.dropLast(1).withIndex())
        edges.add(Edge(p, points[i+1]))
    edges.add(Edge(points.last(), points.first()))

    // build all rectangles
    val rectangles = mutableListOf<Rectangle>()
    for (i in 0 until points.size - 1)
        for (j in i+1 until points.size)
            rectangles.add(Rectangle(points[i], points[j]))

    // find the largest rectangle that doesn't contain any edges
    return rectangles
        .sortedBy { -it.area }
        .first { rect ->
            edges.all { !rect.contains(it) }
        }.area
}