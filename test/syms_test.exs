defmodule SymsTest do
  use ExUnit.Case
  doctest Syms
  test "create_world: starts a world and returns its PID" do
    t = Syms.create_world("World_1001")
    assert is_pid(t) == true
  end
end
