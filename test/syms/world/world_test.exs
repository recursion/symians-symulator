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

    test "has an empty name property", %{world: world} do
      assert world.name == ""
    end

    test "generate_locations: create a map of locations keyed by coordinates" do
      locations = World.generate_locations({5, 5, 5})
      # is a map
      assert is_map(locations)

      # keyed by coordinates
      assert locations[{0, 0, 0}] == %Syms.World.Location{}
      assert locations[{5, 5, 5}] == %Syms.World.Location{}

      # doesnt have locations for coordinates that dont exist
      assert locations[{10, 10, 10}] == nil
    end
  end

  describe "Syms.World" do
    test "is a temporary worker" do
      assert Supervisor.child_spec(Syms.World, []).restart == :temporary
    end

    test "generate_locations: runs generate_locations as a task
    - sends back a map of locations" do
      World.generate_locations({5, 5, 5}, self(), Time.utc_now())

      # it sends back a message when complete
      assert_receive {:locations_generated, _locations, _time}, 1000
    end

    test "generate_locations: runs generate_locations as a task" do
      World.generate_locations({5, 5, 5}, self())

      # it sends back each location as its generated
      assert_receive {:location_generated, _location}, 1000
    end
  end

  describe "put: put a location at a set of coordinates" do
    setup do
      {:ok, world} = start_supervised({Syms.World, :testworld1})
      %{world: world}
    end

    test "only accepts %Syms.World.Location{}'s for the location argument",
      %{world: world} do
      catch_error World.put(world, {0, 0, 0}, "pig")
    end

    test "accepts non default locations", %{world: world} do
      assert World.put(world, {0, 0, 0}, %Syms.World.Location{type_: :grass})
    end
  end

  describe "when initialized" do
    setup do
      {:ok, world} = start_supervised({Syms.World, :testworld2})
      %{world: world}
    end

    test "view returns a %Syms.World{} struct", %{world: world} do
      subject = World.get(world)
      assert subject == %Syms.World{name: "testworld2"}
    end

    test "get returns nil for any set of coordinates", %{world: world} do
      assert World.get(world, {0, 0, 0}) == nil
    end

    test "put puts a location at coordinates", %{world: world} do
      World.put(world, {0, 0, 0}, %Syms.World.Location{})
      Process.sleep(25)
      assert World.get(world, {0, 0, 0}) == %Syms.World.Location{}
    end
  end

  describe "when generate completes" do
    setup do
      {:ok, world} = start_supervised({Syms.World, :testworld})
      World.generate(world, {5, 5, 5})
      Process.sleep(25)
      %{world: world}
    end

    test "locations exist for all coordinates", %{world: world} do
      assert World.get(world).dimensions == {5, 5, 5}
      for l <- 0..5, w <- 0..5, h <- 0..5 do
          locations = World.get(world).locations
          location = locations[{l, w, h}]
          assert location == %Syms.World.Location{}
      end
    end

    test "view returns a dimensioned, locations-populated %Syms.World{} struct",
      %{world: world} do
      subject = World.get(world)
      assert length(Map.to_list(subject.locations)) == 216
    end

    test "get returns the location at coordinates", %{world: world} do
      assert World.get(world, {0, 0, 0}) == %Syms.World.Location{}
    end

    test "put puts an object in/on location at coordinates", %{world: world} do
      World.put(world, {0, 0, 0}, %Syms.World.Location{type_: :air})
      assert World.get(world, {0, 0, 0}) == %Syms.World.Location{type_: :air}
    end
  end
end
