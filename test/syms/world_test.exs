defmodule Syms.WorldTest do
    use ExUnit.Case, async: true
  
    setup do
        {:ok, world} = start_supervised(Syms.World)
        %{world: world}
    end

    test "stores values by key", %{world: world} do
      assert Syms.World.get(world, "milk") == nil
  
      Syms.World.put(world, "milk", 3)
      assert Syms.World.get(world, "milk") == 3
    end

    test "are temporary workers" do
        assert Supervisor.child_spec(Syms.World, []).restart == :temporary
    end
  end