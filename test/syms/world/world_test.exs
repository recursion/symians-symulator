defmodule Syms.WorldTest do
  use ExUnit.Case, async: true

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
    test "has an empty name property", %{world: world} do
      assert world.name == ""
    end
  end

  test "is a temporary worker" do
    assert Supervisor.child_spec(Syms.World, []).restart == :temporary
  end

  describe "put: put a location at a set of coordinates" do
    setup do
      {:ok, world} = start_supervised({Syms.World, :testworld1})
      %{world: world}
    end
    test "throws an error if something other than a %Syms.World.Location is used as the third argument", %{world: world} do
      catch_error Syms.World.put(world, {0, 0, 0}, "pig")
    end
    test "accepts non default locations", %{world: world} do
      assert Syms.World.put(world, {0, 0, 0}, %Syms.World.Location{type: :grass})
    end
  end

  test "generate_locations: create a map of locations keyed by coordinates" do
    locations = Syms.World.generate_locations({5, 5, 5})
    # it is a map
    assert is_map(locations)

    # it is keyed by coordinates
    assert locations["000"] == %Syms.World.Location{}
    assert locations["555"] == %Syms.World.Location{}
    assert locations["101010"] == nil
  end

  test "generate_locations_task: runs a task that creates a map of locations keyed by coordinates" do
    Syms.World.generate_locations({5, 5, 5}, self(), Time.utc_now())

    # it sends back a message when complete
    assert_receive {:locations_generated, _dimensions, _locations, _time}, 1000
  end

  describe "when initialized" do
    setup do
      {:ok, world} = start_supervised({Syms.World, :testworld2})
      %{world: world}
    end

    test "view returns a %Syms.World{} struct", %{world: world} do
      subject = Syms.World.view(world)
      assert subject == %Syms.World{name: "testworld2"}
    end

    test "get returns nil for any set of coordinates", %{world: world} do
      assert Syms.World.get(world, {0, 0, 0}) == nil
    end

    test "put puts a location at coordinates", %{world: world} do
      Syms.World.put(world, {0, 0, 0}, %Syms.World.Location{})
      Process.sleep(25)
      assert Syms.World.get(world, {0, 0, 0}) == %Syms.World.Location{}
    end
  end

  describe "when generate completes" do
    setup do
      {:ok, world} = start_supervised({Syms.World, :testworld})
      Syms.World.generate(world, {5, 5, 5})
      Process.sleep(25)
      %{world: world}
    end

    test "locations exist for all coordinates", %{world: world} do
      assert Syms.World.view(world).dimensions == {5, 5, 5}
      for l <- 0..5, w <- 0..5, h <- 0..5 do
          assert Syms.World.view(world).locations["#{l}#{w}#{h}"] == %Syms.World.Location{}
      end
    end

    test "view returns a dimensioned, locations-populated %Syms.World{} struct", %{world: world} do
      subject = Syms.World.view(world)
      assert length(Map.to_list(subject.locations)) == 216
    end

    test "get returns the location at coordinates", %{world: world} do
      assert Syms.World.get(world, {0, 0, 0}) == %Syms.World.Location{}
    end

    test "put puts an object in/on location at coordinates", %{world: world} do
      Syms.World.put(world, {0, 0, 0}, %Syms.World.Location{type: :air})
      assert Syms.World.get(world, {0, 0, 0}) == %Syms.World.Location{type: :air}
    end
  end
end
