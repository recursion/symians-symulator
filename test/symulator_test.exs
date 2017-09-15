defmodule SymulatorTest do
  use ExUnit.Case
  doctest Symulator
  test "create_world: starts a world and returns its PID" do
    t = Symulator.create_world("World_1001")
    assert is_pid(t) == true
  end
end
