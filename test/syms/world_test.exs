defmodule Syms.WorldTest do
  use ExUnit.Case, async: true
  alias Syms.World

  describe "%Syms.World{}" do
    setup do
      %{world: %Syms.World{}}
    end
    test "has dimensions of {0, 0, 0}", %{world: world} do
      assert world == %Syms.World{}
      assert world.dimensions == {0, 0, 0}
    end

    test "has locations of %{}", %{world: world} do
      assert world == %Syms.World{}
      assert world.locations == %{}
    end
  end

  describe "when initialized" do
    setup do
      {:ok, world} = start_supervised(Syms.World)
      %{world: world}
    end

    test "view returns a %Syms.World{} struct", %{world: world} do
      subject = World.view(world)
      assert subject == %Syms.World{}
    end

    test "get returns nil for any set of coordinates", %{world: world} do
      assert World.get(world, {0, 0, 0}) == nil
    end

    test "put puts a location at coordinates", %{world: world} do
      assert World.get(world, {0, 0, 0}) == nil
      World.put(world, {0, 0, 0}, %Syms.World.Location{})
      assert World.get(world, {0, 0, 0}) == %Syms.World.Location{}
    end
  end

  describe "when generate completes" do
    setup do
      {:ok, world} = start_supervised(Syms.World)
      World.generate(world, {5, 5, 5})
      Process.sleep(25)
      %{world: world}
    end

    test "locations exist for all coordinates", %{world: world} do
      assert Syms.World.view(world).dimensions == {5, 5, 5}
      for l <- 0..5, w <- 0..5, h <- 0..5 do
          assert World.view(world).locations["#{l}#{w}#{h}"] == %Syms.World.Location{}
      end
    end

    test "World.view returns a dimensioned, locations-populated %Syms.World{} struct", %{world: world} do
      subject = World.view(world)
      assert length(Map.to_list(subject.locations)) == 216
    end

    test "World.get returns the location at coordinates", %{world: world} do
      assert World.get(world, {0, 0, 0}) == %Syms.World.Location{}
    end

    # TODO: change this code to test that we put a new location at coordinates
    test "World.put puts an object in/on location at coordinates", %{world: world} do
      World.put(world, {0, 0, 0}, %Syms.World.Location{})
      assert World.get(world, {0, 0, 0}) == %Syms.World.Location{}
    end
  end
end
