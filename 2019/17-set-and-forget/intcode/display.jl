module Display

const ESC = "\u001B"
goto(x, y) = print("$ESC[$(y);$(x)H")
clear() = print("$ESC[2J")
savecursor() = print("$ESC[s")
restorecursor() = print("$ESC[u")

end