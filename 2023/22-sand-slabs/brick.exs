defmodule Brick do
  defstruct start: {0, 0, 0}, end: {0, 0, 0}

  def intersects?(brick1, brick2) do
    {ax1, ay1, az1} = brick1.start
    {ax2, ay2, az2} = brick1.end
    {bx1, by1, bz1} = brick2.start
    {bx2, by2, bz2} = brick2.end

    if az1 > bz2 or az2 < bz1 do
      false
    else
      a1 = {ax1, ay1}
      a2 = {ax2, ay2}
      b1 = {bx1, by1}
      b2 = {bx2, by2}
      da = subtract(a2, a1)
      db = subtract(b2, b1)
      a1b1 = subtract(b1, a1)
      a1b2 = subtract(b2, a1)
      b1a1 = subtract(a1, b1)
      b1a2 = subtract(a2, b1)

      cross1 = cross(da, a1b1)
      cross2 = cross(da, a1b2)
      cross3 = cross(db, b1a1)
      cross4 = cross(db, b1a2)

      different_sides = cross1 * cross2 < 0 and cross3 * cross4 < 0
      collinear = cross1 == 0 or cross2 == 0 or cross3 == 0 or cross4 == 0

      cond do
        different_sides -> true
        collinear -> check_overlap(a1, a2, b1, b2)
        true -> false
      end
    end
  end

  # check if two lines overlap
  def check_overlap({ax1, ay1}, {ax2, ay2}, {bx1, by1}, {bx2, by2}) do
    overlap_on_x = min(ax1, ax2) <= max(bx1, bx2) && max(ax1, ax2) >= min(bx1, bx2)
    overlap_on_y = min(ay1, ay2) <= max(by1, by2) && max(ay1, ay2) >= min(by1, by2)

    overlap_on_x && overlap_on_y
  end

  # subtract two vectors
  def subtract({x1, y1}, {x2, y2}) do
    {x1 - x2, y1 - y2}
  end

  # cross product of two vectors
  def cross({x1, y1}, {x2, y2}) do
    x1 * y2 - x2 * y1
  end

  # drop bricks down until they hit something
  def drop_bricks(bricks_remaining, bricks_dropped \\ []) do
    case bricks_remaining do
      [] -> bricks_dropped |> Enum.reverse()
      [brick | rest] ->
        {x1, y1, z1} = brick.start
        {x2, y2, z2} = brick.end
        if z1 == 1 do
          drop_bricks(rest, [brick | bricks_dropped])
        else
          brick = Enum.reduce_while(z1..2, brick, fn new_z, _brick ->
            if Enum.any?(bricks_dropped, fn b -> intersects?(b, %Brick{start: {x1, y1, new_z - 1}, end: {x2, y2, z2 - (z1 - new_z) - 1}}) end) do
              {:halt, %Brick{start: {x1, y1, new_z}, end: {x2, y2, z2 - (z1 - new_z)}}}
            else
              {:cont, %Brick{start: {x1, y1, new_z - 1}, end: {x2, y2, z2 - (z1 - new_z) - 1}}}
            end
          end)
          drop_bricks(rest, [brick | bricks_dropped])
        end
    end
  end

  # return the bricks directly above the given brick
  def bricks_above(bricks, brick) do
    # {x1, y1, z1} = brick.start
    {_, _, z2} = brick.end

    bricks
    |> Enum.filter(fn b ->
      {bx1, by1, bz1} = b.start
      {bx2, by2, bz2} = b.end
      bz1 == z2 + 1 and intersects?(brick, %Brick{start: {bx1, by1, bz1 - 1}, end: {bx2, by2, bz2 - 1}})
    end)
  end

  # return the bricks directly below the given brick
  def bricks_below(bricks, brick) do
    {_, _, z1} = brick.start
    # {x2, y2, z2} = brick.end

    bricks
    |> Enum.filter(fn b ->
      {bx1, by1, bz1} = b.start
      {bx2, by2, bz2} = b.end
      bz2 == z1 - 1 and intersects?(brick, %Brick{start: {bx1, by1, bz1 + 1}, end: {bx2, by2, bz2 + 1}})
    end)
  end

  # def bricks_above?(bricks, brick) do
  #   {x1, y1, z1} = brick.start
  #   {x2, y2, _z2} = brick.end

  #   bricks
  #   |> Enum.filter(fn b -> {_, _, z} = b.start; z > z1 end) # possible bricks above
  #   |> Enum.any?(fn b ->
  #     {_, _, z} = b.start
  #     intersects?(b, %Brick{start: {x1, y1, z}, end: {x2, y2, z}})
  #   end)
  # end

  def new(line) do
    [x1, y1, z1, x2, y2, z2] =
      line
      |> String.split(~r/\D/, trim: true)
      |> Enum.map(fn x -> String.to_integer(x) end)

    # it looks like start z is always smaller than end z, but just in case...
    {s, e} = if z1 <= z2, do: {{x1, y1, z1}, {x2, y2, z2}}, else: {{x2, y2, z2}, {x1, y1, z1}}
     %Brick{start: s, end: e}
  end
end
