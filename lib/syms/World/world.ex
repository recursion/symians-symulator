defmodule Syms.World do
    use Agent, restart: :temporary

    @doc """
    Starts a new world.
    """
    def start_link(opts) do
        Agent.start_link(fn -> 
            init_world(opts) 
        end)
    end

    def init_world(opts) do
        %{}
    end

    @doc """
    Gets a location from the `world` by `coordinates`.
            where `coordinates` is a `key` created from the 
            locations x, y, z coordinates
    """
    def get(world, coordinates) do
        Agent.get(world, &Map.get(&1, coordinates))
    end

    @doc """
    attempts to put a game object on a `location` 
    for the given `coordinates` in the `world`.
        ## TODO: Some checks to make sure an object can be moved here
    """
    def put(world, coordinates, game_object) do
        Agent.update(world, &Map.put(&1, coordinates, game_object))
    end

    def delete(world, coordinates) do
        Agent.get_and_update(world, fn dict ->
          Map.pop(dict, coordinates)
        end)
    end
end