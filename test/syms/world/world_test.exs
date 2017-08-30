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

end
