ExUnit.start()

defmodule BrickTest do
  use ExUnit.Case

  test "intersects" do
    b1 = Brick.new("1,0,1~1,2,1")
    b2 = Brick.new("0,0,2~2,0,2")
    assert !Brick.intersects?(b1, b2)

    b1 = Brick.new("1,0,1~1,2,1")
    b2 = Brick.new("0,0,1~2,0,1")
    assert Brick.intersects?(b1, b2)

    b1 = Brick.new("1,0,1~1,2,1")
    b2 = Brick.new("1,0,1~1,2,1")
    assert Brick.intersects?(b1, b2)

    b1 = Brick.new("0,0,1~0,0,1")
    b2 = Brick.new("1,0,1~1,0,1")
    assert !Brick.intersects?(b1, b2)
  end
end
