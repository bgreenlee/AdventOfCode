import java.io.File
import com.google.ortools.Loader
import com.google.ortools.linearsolver.MPSolver

typealias Panel = List<Boolean>
typealias Button = List<Int>

fun main() {
    val input = File("data/input.dat").readLines()
    val panels = mutableListOf<Panel>()
    val buttons = mutableListOf<List<Button>>()
    val joltages = mutableListOf<List<Int>>()

    for (line in input) {
        val parts = line.split(" ")
        panels.add(
            parts.first()
                .trim('[',']')
                .toCharArray()
                .map { it == '#' }
        )
        buttons.add(
            parts.slice(1 until parts.size - 1)
                .map {
                    it.trim('(', ')')
                        .split(",")
                        .map { it.toInt() }
                }
        )
        joltages.add(
            parts.last()
                .trim('{','}')
                .split(",")
                .map { it.toInt() }
        )
    }

    println("part 1: " + part1(panels, buttons))
    println("part 2: " + part2(buttons, joltages))
}

fun <T> Collection<T>.powerset(): List<List<T>> = when {
    isEmpty() -> listOf(listOf())
    else -> drop(1).powerset().let { it + it.map { it + first() } }
}

fun pressPanelButtons(buttons: List<Button>, panelSize: Int): Panel {
    val panel = MutableList(panelSize) { false }
    for (button in buttons)
        for (i in button)
            panel[i] = !panel[i]

    return panel
}

fun part1(panels: List<Panel>, buttonsList: List<List<Button>>): Int {
    val presses = mutableListOf<Int>()
    for ((i, buttons) in buttonsList.withIndex()) {
        for (maxPresses in 1..1) {
            val expandedButtons = buttons.flatMap { button ->
                List(maxPresses) { button }
            }
            val targetPanel = panels[i]
            var minPresses = Int.MAX_VALUE
            for (buttonSet in expandedButtons.powerset()) {
                val panel = pressPanelButtons(buttonSet, targetPanel.size)
                if (panel == targetPanel) {
                    minPresses = minOf(minPresses, buttonSet.size)
                }
            }
            presses.add(minPresses)
        }
    }
    return presses.sum()
}

fun part2(buttonsList: List<List<Button>>, joltages: List<List<Int>>): Int {
    Loader.loadNativeLibraries()
    val solver = MPSolver.createSolver("SCIP")

    return buttonsList.mapIndexed { i, buttons ->
        // for upper bound, get max of joltages
        val upperBound = joltages[i].max().toDouble()
        val buttonVars = buttons.indices.map { j ->
            solver.makeIntVar(0.0, upperBound, "btn_$j")
        }

        joltages[i].forEachIndexed { i, joltage ->
            val constraint = solver.makeConstraint(joltage.toDouble(), joltage.toDouble())
            buttons.forEachIndexed { j, button ->
                if (i in button) {
                    constraint.setCoefficient(buttonVars[j], 1.0)
                }
            }
        }

        // solve for minimum presses
        val objective = solver.objective()
        buttonVars.forEach { objective.setCoefficient(it, 1.0) }
        objective.setMinimization()
        solver.solve()
        buttonVars.sumOf { it.solutionValue().toLong() }.toInt()
    }.sum()
}
