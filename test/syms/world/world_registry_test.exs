defmodule Syms.World.RegistryTest do
  use ExUnit.Case, async: true

  setup context do
    {:ok, _} = start_supervised({Syms.World.Registry, name: context.test})
    %{registry: context.test}
  end

  test "spawns worlds", %{registry: registry} do
    name = "homeworld1"
    assert Syms.World.Registry.lookup(registry, name) == :error
    Syms.World.Registry.create(registry, name)
    assert {:ok, _world} = Syms.World.Registry.lookup(registry, name)
  end

  test "removes worlds on exit", %{registry: registry} do
    name = "homeworld2"
    Syms.World.Registry.create(registry, name)
    {:ok, world} = Syms.World.Registry.lookup(registry, name)

    GenServer.stop(world)

    Syms.World.Registry.create(registry, "bogus")
    assert Syms.World.Registry.lookup(registry, name) == :error
  end

  test "removes worlds on crash", %{registry: registry} do
    Syms.World.Registry.create(registry, "world1")
    {:ok, world} = Syms.World.Registry.lookup(registry, "world1")
    # Stop the world with non-normal reason
    GenServer.stop(world, :shutdown)

    Syms.World.Registry.create(registry, "bogus2")
    assert Syms.World.Registry.lookup(registry, "world1") == :error
  end
end
