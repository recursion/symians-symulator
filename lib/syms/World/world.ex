defmodule Syms.World do
    use GenServer

    @moduledoc """
    a world is a %Map{} of locations keyed by coordinates
    `dimensions` is the length, width, and height of the world
    """
    defstruct dimensions: {0, 0, 0}, locations: %{}
                         
    @doc """
    Creates an empty world
    """
    def start_link(options \\ []) do
        GenServer.start_link(Syms.World.Server, :ok, options)
    end

    @doc """
    create a world from dimensions
    """
    def create(world, dimensions) do
        GenServer.cast(world, {:create, dimensions})
    end

    @doc """
    return the entire world
    """
    def view(world) do
        GenServer.call(world, {:view})
    end

    @doc """
    returns the location stored in the key `coordinates`
    """
    def get(world, coordinates) do
        GenServer.call(world, {:get, coordinates})
    end

    @doc """
    put object at location coordinates
    """
    def put(world, coordinates, game_object) do
        current_location = get(world, coordinates)
        next_location = Syms.World.Location.put(current_location, game_object)
        GenServer.call(world, {:update_location, coordinates, next_location})
    end
end