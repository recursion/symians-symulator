defmodule Symulator.World.CoordinatesTest do
  use ExUnit.Case, async: true
  
  test "to_string: converts a tuple to a string" do
    assert Symulator.World.Coordinates.to_string({5, 5, 5}) == "5|5|5"
  end

  test "from_string converts a string to a tuple" do
    assert Symulator.World.Coordinates.from_string("5|5|5") == {5, 5, 5}
  end
end
