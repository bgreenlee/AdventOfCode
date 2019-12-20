module Display

const ESC = "\u001B"
goto(x, y) = print("$ESC[$(y);$(x)H")

end