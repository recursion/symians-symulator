defmodule SymulatorTest do
  use ExUnit.Case
  doctest Symulator
  test "create_world: starts a world and returns its PID" do
    t = Symulator.create_world("World_1001")
    assert is_pid(t) == true
  end

  test "lookup: returns :ok and the pid of an existing world" do
    a = Symulator.create_world("World_1002")
    {:ok, b} = Symulator.lookup("World_1002")
    assert a == b
  end
  test "lookup: returns :error when the world is not found" do
    assert Symulator.lookup("World_1004") == :error
  end

  test "getArea: returns a matrix of locations" do
    assert 1 == 2
  end
end
