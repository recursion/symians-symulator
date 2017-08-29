defmodule Syms.RegistryTest do
  use ExUnit.Case, async: true

  setup context do
    {:ok, _} = start_supervised({Syms.World.Registry, name: context.test})
    %{registry: context.test, name: "homeworld1"}
  end

  test "spawns worlds", %{registry: registry, name: name} do
    assert Syms.World.Registry.lookup(registry, name) == :error
    Syms.World.Registry.create(registry, name)
    assert {:ok, _world} = Syms.World.Registry.lookup(registry, name)
  end

  test "removes worlds on exit", %{registry: registry, name: name} do
    Syms.World.Registry.create(registry, name)
    {:ok, world} = Syms.World.Registry.lookup(registry, name)

    GenServer.stop(world)

    reg_call(registry)
    assert Syms.World.Registry.lookup(registry, name) == :error
  end

  test "removes worlds on crash", %{registry: registry} do
    Syms.World.Registry.create(registry, "world1")
    {:ok, world} = Syms.World.Registry.lookup(registry, "world1")
    # Stop the world with non-normal reason
    GenServer.stop(world, :shutdown)

    reg_call(registry)
    assert Syms.World.Registry.lookup(registry, "world1") == :error
  end

  # helpers
  def reg_call(registry) do
    # Do a call to ensure the registry processed the DOWN message
    _ = Syms.World.Registry.create(registry, "bogus")
  end
end
