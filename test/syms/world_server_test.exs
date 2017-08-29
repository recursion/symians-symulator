defmodule Syms.WorldServerTest do
    use ExUnit.Case, async: true
  
    test "generate_locations: create a map of locations keyed by coordinates" do
        locations = Syms.World.Server.generate_locations({5, 5, 5})
        # it is a map
        assert is_map(locations)

        # it is keyed by coordinates
        assert locations["000"] == []
        assert locations["555"] == []
        assert locations["101010"] == nil
    end

    test "generate_locations_task: runs a task that creates a map of locations keyed by coordinates" do
        Syms.World.Server.generate_locations_async({5, 5, 5}, self(), Time.utc_now())

        # it sends back a message when complete
        assert_receive {:locations_generated, _dimensions, _locations, _process_time}, 1000
    end
end