defmodule Symulator.World.RegistryTest do
  use ExUnit.Case, async: true

  setup context do
    {:ok, _} = start_supervised({Symulator.World.Registry, name: context.test})
    %{registry: context.test}
  end

  test "spawns worlds", %{registry: registry} do
    name = "homeworld1"
    assert Symulator.World.Registry.lookup(registry, name) == :error
    Symulator.World.Registry.create(registry, name)
    assert {:ok, _world} = Symulator.World.Registry.lookup(registry, name)
  end

  test "removes worlds on exit", %{registry: registry} do
    name = "homeworld2"
    Symulator.World.Registry.create(registry, name)
    {:ok, world} = Symulator.World.Registry.lookup(registry, name)

    GenServer.stop(world)

    Symulator.World.Registry.create(registry, "bogus")
    assert Symulator.World.Registry.lookup(registry, name) == :error
  end

  test "removes worlds on crash", %{registry: registry} do
    Symulator.World.Registry.create(registry, "world1")
    {:ok, world} = Symulator.World.Registry.lookup(registry, "world1")
    # Stop the world with non-normal reason
    GenServer.stop(world, :shutdown)

    Symulator.World.Registry.create(registry, "bogus2")
    assert Symulator.World.Registry.lookup(registry, "world1") == :error
  end
end
